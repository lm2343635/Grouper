//
//  AddMemberViewController.m
//  GroupFinance
//
//  Created by lidaye on 22/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AddMemberViewController.h"
#import "DaoManager.h"
#import "AppDelegate.h"
#import "GroupTool.h"
#import "InternetTool.h"
#import "AlertTool.h"

@interface AddMemberViewController ()

@property (nonatomic, strong) AppDelegate *delegate;
@property (nonatomic, strong) NSMutableArray *connectedPeers;

- (void)peerDidChangeStateWithNotification: (NSNotification *)notification;
- (void)didReceiveDataWithNotification: (NSNotification *)notification;

@end

@implementation AddMemberViewController {
    DaoManager *dao;
    User *currentUser;
    GroupTool *group;
    BOOL isOwner;
    NSMutableDictionary *serverInfoForUser;
    MCPeerID *invitePeer;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }

    dao = [[DaoManager alloc] init];
    currentUser = [dao.userDao getUsingUser];
    group = [[GroupTool alloc] init];
    isOwner = [group.owner isEqualToString:currentUser.uid];
    
    _delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [_delegate.mcManager setupPeerAndSessionWithDisplayName:currentUser.name];
    [_delegate.mcManager advertiseSelf:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCDidChangeStateNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    _connectedPeers = [[NSMutableArray alloc] init];
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return 0.1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return _connectedPeers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"deviceIdentifier"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [[_connectedPeers objectAtIndex:indexPath.row] displayName];
    //If this user is the owner of group, he can invite
    if (isOwner) {
        cell.detailTextLabel.text = @"Invite";
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    //If this user is the owner of group, he can invite
    if (isOwner) {
        invitePeer = [_connectedPeers objectAtIndex:indexPath.row];
        NSString *message = [NSString stringWithFormat:@"Invite %@ to your group.", invitePeer.displayName];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Invite"
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];
        UIAlertAction *invite = [UIAlertAction actionWithTitle:@"Yes"
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self sendMessage:@{@"task": @"invite"} to:invitePeer];
                                                       }];
        [alertController addAction:cancel];
        [alertController addAction:invite];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - MCBrowserViewControllerDelegate
-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [_delegate.mcManager.browserViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [_delegate.mcManager.browserViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Action
- (IBAction)browseForDevices:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [_delegate.mcManager setupMCBrowser];
    [_delegate.mcManager.browserViewController setDelegate:self];
    [self presentViewController:_delegate.mcManager.browserViewController
                       animated:YES
                     completion:nil];
}

#pragma mark - Notification
- (void)peerDidChangeStateWithNotification:(NSNotification *)notification {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    if (state != MCSessionStateConnecting) {
        if (state == MCSessionStateConnected) {
            [_connectedPeers addObject:peerID];
        } else if (state == MCSessionStateNotConnected) {
            if(_connectedPeers.count > 0) {
                [_connectedPeers removeObject:peerID];
            }
        }
        [_devicesTableView reloadData];

    }
}

- (void)didReceiveDataWithNotification:(NSNotification *)notification {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    NSData *data = [[notification userInfo] objectForKey:@"data"];
    NSDictionary *message = [NSJSONSerialization JSONObjectWithData:data
                                                            options:NSJSONReadingMutableContainers
                                                              error:nil];
    if (DEBUG) {
        NSLog(@"Received message from %@: %@", peerDisplayName, message);
    }
    NSString *task = [message valueForKey:@"task"];
    if ([task isEqualToString:@"invite"] && !isOwner) {
        [self sendMessage:@{
                            @"task": @"sendUserInfo",
                            @"userInfo": @{
                                        @"uid": currentUser.uid,
                                        @"email": currentUser.email,
                                        @"name": currentUser.name,
                                        @"gender": currentUser.gender,
                                        @"pictureUrl": currentUser.pictureUrl,
                                    }
                            }
                       to:peerID];
    } else if ([task isEqualToString:@"sendUserInfo"] && isOwner) {
        //Set count for HTTP request.
        self.sent = 0;
        [self addObserver:self
               forKeyPath:@"sent"
                  options:NSKeyValueObservingOptionOld
                  context:nil];
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[message valueForKey:@"userInfo"]];
        [parameters setValue:@NO forKey:@"owner"];
        //Init serverInfoForUser
        serverInfoForUser = [[NSMutableDictionary alloc] init];
        //Send user info to untrusted servers.
        for (NSString *address in group.servers.allKeys) {
            AFHTTPSessionManager *manager = [InternetTool getSessionManagerWithServerAddress:address];
            [manager POST:[InternetTool createUrl:@"user/add" withServerAddress:address]
               parameters:parameters
                 progress:nil
                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                      InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                      if ([response statusOK]) {
                          NSObject *result = [response getResponseResult];
                          NSString *accesskey = [result valueForKey:@"accesskey"];
                          [serverInfoForUser setValue:accesskey forKey:address];
                          NSLog(@"%@ serverInfoForUser %@", address, serverInfoForUser);
                          //All task finished, sent plus 1
                          self.sent ++;
                      }
                  }
                  failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                      InternetResponse *response = [[InternetResponse alloc] initWithError:error];
                      switch ([response errorCode]) {
                      
                      }
                  }];
        }
    } else if ([task isEqualToString:@"sendServerInfo"] && !isOwner) {
        //Receive server information and access key from group owner.
        group.servers = [message valueForKey:@"serverInfo"];
        [self sendMessage:@{@"task": @"joinSuccess"} to:peerID];
        //Download group members and group info.
        NSString *address0 = [group.servers.allKeys objectAtIndex:0];
        NSDictionary *managers = [InternetTool getSessionManagers];
        [managers[address0] GET:[InternetTool createUrl:@"group/info" withServerAddress:address0]
                     parameters:nil
                       progress:nil
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                            if ([response statusOK]) {
                                NSObject *result = [response getResponseResult];
                                NSObject *groupInfo = [result valueForKey:@"group"];
                                group.groupId = [groupInfo valueForKey:@"id"];
                                group.groupName = [groupInfo valueForKey:@"name"];
                                group.members = [[groupInfo valueForKey:@"members"] integerValue];
                                group.owner = [groupInfo valueForKey:@"oid"];
                                [AlertTool showAlertWithTitle:@"Tip"
                                                   andContent:[NSString stringWithFormat:@"You have joined to %@.", group.groupName]
                                             inViewController:self];
                            }
                        }
                        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                            InternetResponse *response = [[InternetResponse alloc] initWithError:error];
                            switch ([response errorCode]) {
                                    
                            }
                        }];
        //Reload user info
        [managers[address0] GET:[InternetTool createUrl:@"user/list" withServerAddress:address0]
                     parameters:nil
                       progress:nil
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                            if ([response statusOK]) {
                                NSObject *result = [response getResponseResult];
                                NSArray *users = [result valueForKey:@"users"];
                                for(NSObject *user in users) {
                                    if ([currentUser.uid isEqualToString:[user valueForKey:@"id"]]) {
                                        continue;
                                    }
                                    [dao.userDao saveOrUpdateWithJSONObject:user fromUntrustedServer:YES];
                                }
                            }
                        }
                        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                            InternetResponse *response = [[InternetResponse alloc] initWithError:error];
                            switch ([response errorCode]) {
                                    
                            }
                        }];
        
    } else if ([task isEqualToString:@"joinSuccess"] && isOwner) {
        //Joined group successfully. Add this user to user list.
        [AlertTool showAlertWithTitle:@"Tip"
                           andContent:@"Invite this user successfully!"
                     inViewController:self];
    }
}

#pragma mark - Service
- (void)sendMessage:(NSDictionary *)message to:(MCPeerID *)peer {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:message
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
    NSError *error;
    [_delegate.mcManager.session sendData:data
                                  toPeers:[NSArray arrayWithObject:peer]
                                 withMode:MCSessionSendDataReliable
                                    error:&error];
    if(error) {
        NSLog(@"Error in sending: %@", error.localizedDescription);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([keyPath isEqualToString:@"sent"]) {
        if (DEBUG) {
            NSLog(@"Send user's information to %d untrusted servers successfully.", self.sent);
        }
        //Send owner's information to all untrusted servers successfully.
        if (self.sent == group.servers.count) {
            if (DEBUG) {
                NSLog(@"Send user's information to all untrusted servers successfully!");
            }
            [self removeObserver:self forKeyPath:@"sent"];
            //Send access keys and server information to joiner.
            NSLog(@"serverInfoForUser = %@", serverInfoForUser);
            NSLog(@"invitePeer = %@", invitePeer);
            [self sendMessage:@{
                                @"task": @"sendServerInfo",
                                @"serverInfo": serverInfoForUser
                                }
                           to:invitePeer];
            
        }
    }
}
@end
