//
//  ServersTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 19/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "ServersTableViewController.h"
#import "GroupTool.h"
#import "InternetTool.h"
#import "DaoManager.h"
#import "AlertTool.h"

@interface ServersTableViewController ()

@end

@implementation ServersTableViewController {
    GroupTool *group;
    NSDictionary *servers;
    DaoManager *dao;
    User *user;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao = [[DaoManager alloc] init];
    user = [dao.userDao getUsingUser];
}

- (void)viewWillAppear:(BOOL)animated {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    group = [[GroupTool alloc] init];
    servers = group.servers;
    switch (group.initial) {
        case NotInitial:
            _noServerLabel.hidden = NO;
            _groupInformationView.hidden = YES;
            break;
        case RestoringServer:
            _addServerBarButtonItem.enabled = NO;
            _noServerLabel.hidden = YES;
            break;
        case AddingNewServer:
            _restoreServerBarButtonItem.enabled = NO;
            _noServerLabel.hidden = YES;
            break;
        case InitialFinished:
            _addServerBarButtonItem.enabled = NO;
            _restoreServerBarButtonItem.enabled = NO;
            break;
        default:
            break;
    }
    //Show group id and group name if group state is not uninitial.
    if (group.initial != NotInitial) {
        _groupIdTextField.text = group.groupId;
        _groupNameTextField.text = group.groupName;
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return 0.1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return servers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"serverIdentifier"
                                                            forIndexPath:indexPath];
    UILabel *addressLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *accessKeyLabel = (UILabel *)[cell viewWithTag:2];
    addressLabel.text = [[servers allKeys] objectAtIndex:indexPath.row];
    accessKeyLabel.text = [servers valueForKey:addressLabel.text];
    return cell;
}

#pragma mark - Action
- (IBAction)initialGroup:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Initialize Group"
                                                                   message:@"You cannot add more untrusted server after initializing your group. Are you sure to initialize?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *initialize = [UIAlertAction actionWithTitle:@"Yes"
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           switch (group.initial) {
                                                               case RestoringServer:
                                                                   [self restoreUntrustedServers];
                                                                   break;
                                                               case AddingNewServer:
                                                                   [self registerOwnerInUntrustedServers];
                                                                   break;
                                                               default:
                                                                   break;
                                                           }
                                                           
                                                       }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alertController addAction:initialize];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

#pragma mark - Service

- (void)restoreUntrustedServers {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    //Confirm the number of untrusted servers
    //TODO List
    if (group.servers.count != 0) {
        
    }
    
    //Hide initial group button and add server bar button
    _initialGroupButton.hidden = YES;
    _restoreServerBarButtonItem.enabled = NO;
    //Change initial state.
    group.initial = InitialFinished;
    
    [AlertTool showAlertWithTitle:@"Tip"
                       andContent:[NSString stringWithFormat:@"%@ has been initialized successfully!", group.groupName]
                 inViewController:self];
}

- (void)registerOwnerInUntrustedServers {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    _initialGroupButton.enabled = NO;
    NSDictionary *managers = [InternetTool getSessionManagers];
    //Set count for HTTP request.
    self.sent = 0;
    [self addObserver:self
           forKeyPath:@"sent"
              options:NSKeyValueObservingOptionOld
              context:nil];
    for (NSString *address in managers.allKeys) {
        [managers[address] POST:[InternetTool createUrl:@"user/add" withServerAddress:address]
                     parameters:@{
                                  @"uid": user.uid,
                                  @"name": user.name,
                                  @"email": user.email,
                                  @"gender": user.gender,
                                  @"pictureUrl": user.pictureUrl,
                                  @"owner": @YES
                                  }
                       progress:nil
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                            if ([response statusOK]) {
                                self.sent ++;
                            }
                        }
                        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                            _initialGroupButton.enabled = YES;
                            InternetResponse *response = [[InternetResponse alloc] initWithError:error];
                            switch ([response errorCode]) {
                                case ErrorMasterKey:
                                    [AlertTool showAlertWithTitle:@"Warning"
                                                       andContent:@"Your master key is wrong!"
                                                 inViewController:self];
                                    break;
                                case ErrorAddUser:
                                    [AlertTool showAlertWithTitle:@"Warning"
                                                       andContent:@"Add owner failed in server, try again later."
                                                 inViewController:self];
                                    break;
                                default:
                                    break;
                            }
                        }];
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
            NSLog(@"Send owner's information to %ld untrusted servers successfully.", (long)self.sent);
        }
        //Send owner's information to all untrusted servers successfully.
        if (self.sent == group.servers.count) {
            if (DEBUG) {
                NSLog(@"Send owner's information to all untrusted servers successfully!");
            }
            [self removeObserver:self forKeyPath:@"sent"];
            //Set owner and update number of group memebers
            group.owner = user.uid;
            group.members ++;
            //Hide initial group button and add server bar button
            _initialGroupButton.hidden = YES;
            _addServerBarButtonItem.enabled = NO;
            //Change initial state.
            group.initial = InitialFinished;
            
            [AlertTool showAlertWithTitle:@"Tip"
                               andContent:[NSString stringWithFormat:@"%@ has been initialized successfully!", group.groupName]
                         inViewController:self];
        }
    }
}

@end
