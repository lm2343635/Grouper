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
        MCPeerID *peer = [_connectedPeers objectAtIndex:indexPath.row];
        NSString *message = [NSString stringWithFormat:@"Invite %@ to your group.", peer.displayName];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Invite"
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];
        UIAlertAction *invite = [UIAlertAction actionWithTitle:@"Yes"
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self sendMessage:@{@"task": @"invite"} to:peer];
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
        //Send user info to untrusted servers.
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
@end
