//
//  ServersTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 19/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "ServersTableViewController.h"
#import "GroupManager.h"
#import "DaoManager.h"
#import "InternetTool.h"
#import "AlertTool.h"
#import "CommonTool.h"

@interface ServersTableViewController ()

@end

@implementation ServersTableViewController {
    NSDictionary *managers;
    GroupManager *group;
    DaoManager *dao;
    NSDictionary *servers;
    User *user;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao = [DaoManager sharedInstance];
    user = [dao.userDao currentUser];
    group = [GroupManager sharedInstance];
}

- (void)viewWillAppear:(BOOL)animated {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    servers = group.defaults.servers;
    
    switch (group.defaults.initial) {
        case NotInitial:
            _noServerLabel.hidden = NO;
            _groupInformationView.hidden = YES;
            break;
        case RestoringServer:
            _addServerBarButtonItem.enabled = NO;
            _noServerLabel.hidden = YES;
            _initialGroupButton.hidden = NO;
            break;
        case AddingNewServer:
            _restoreServerBarButtonItem.enabled = NO;
            _noServerLabel.hidden = YES;
            _initialGroupButton.hidden = NO;
            break;
        case InitialFinished:
            _addServerBarButtonItem.enabled = NO;
            _restoreServerBarButtonItem.enabled = NO;
            break;
        default:
            break;
    }
    
    //Show group id and group name if group state is not uninitial.
    if (group.defaults.initial != NotInitial) {
        _groupInformationView.hidden = NO;
        _groupIdTextField.text = group.defaults.groupId;
        _groupNameTextField.text = group.defaults.groupName;
    }
    
    if (group.defaults.initial == InitialFinished || group.defaults.initial == RestoringServer) {
        _thresholdTextField.text = [NSString stringWithFormat:@"Threshold is %ld", (long)group.defaults.threshold];
        [_thresholdTextField setEnabled:NO];
    }
    
    //Set keyboard accessory for threshold text field
    [self setCloseKeyboardAccessoryForSender:_thresholdTextField];
    
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
    //Validate threshold when user wants to create a new group.
    //Threshold need not to validate when user wants to restore an existed group.
    if (group.defaults.initial == AddingNewServer) {
        if ([_thresholdTextField.text isEqualToString:@""]) {
            [AlertTool showAlertWithTitle:@"Tip"
                               andContent:@"Recover threshold cannot be empty!"
                         inViewController:self];
            return;
        }
        if (![CommonTool isInteger:_thresholdTextField.text]) {
            [AlertTool showAlertWithTitle:@"Tip"
                               andContent:@"Recover threshold should be an integer!"
                         inViewController:self];
            return;
        }
        int threshold = _thresholdTextField.text.intValue;
        if (threshold < 1 || threshold > group.defaults.servers.allKeys.count) {
            [AlertTool showAlertWithTitle:@"Tip"
                               andContent:@"Recover threshold be more than 0 and less than the number of servers."
                         inViewController:self];
            return;
        }
        if ([_thresholdTextField isFirstResponder]) {
            [_thresholdTextField resignFirstResponder];
        }
    }
    //Check the number of untrusted servers if user wants to initialize by restoring an existed group.
    else if (group.defaults.initial == RestoringServer) {
        if (group.defaults.servers.allKeys.count != group.defaults.serverCount) {
            [AlertTool showAlertWithTitle:@"Tip"
                               andContent:[NSString stringWithFormat:@"%ld servers needed to initialize by restoring your group.", (long)group.defaults.serverCount]
                         inViewController:self];
            return;
        }
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Initialize Group"
                                                                   message:@"You cannot add more untrusted server after initializing your group. Are you sure to initialize?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *initialize = [UIAlertAction actionWithTitle:@"Yes"
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           switch (group.defaults.initial) {
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
    //Hide initial group button and add server bar button
    _initialGroupButton.hidden = YES;
    _restoreServerBarButtonItem.enabled = NO;
    //Change initial state.
    group.defaults.initial = InitialFinished;
    
    [AlertTool showAlertWithTitle:@"Tip"
                       andContent:[NSString stringWithFormat:@"%@ has been initialized successfully!", group.defaults.groupName]
                 inViewController:self];
}

- (void)registerOwnerInUntrustedServers {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }

    _initialGroupButton.enabled = NO;
    
    //Set count for HTTP request.
    self.setOwner = 0;
    [self addObserver:self
           forKeyPath:@"setOwner"
              options:NSKeyValueObservingOptionOld
              context:nil];
    
    //Refresh session manager.
    [InternetTool refreshSessionManagers];
    managers = [InternetTool getSessionManagers];
    
    //Send owner information
    for (NSString *address in managers.allKeys) {

        [managers[address] POST:[InternetTool createUrl:@"user/add" withServerAddress:address]
                     parameters:@{
                                  @"userId": user.userId,
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
                                self.setOwner ++;
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

- (void)submitServerCountAndThreshold {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self.setThreshold = 0;
    [self addObserver:self
           forKeyPath:@"setThreshold"
              options:NSKeyValueObservingOptionOld
              context:nil];
    
    for (NSString *address in managers.allKeys) {
        [managers[address] POST:[InternetTool createUrl:@"group/init" withServerAddress:address]
                     parameters:@{
                                  @"servers": [NSNumber numberWithInteger:managers.allKeys.count],
                                  @"threshold": [NSNumber numberWithInt:_thresholdTextField.text.intValue]
                                  }
                       progress:nil
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                            if ([response statusOK]) {
                                self.setThreshold ++;
                            }
                        }
                        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                            
                        }];
    }
}

//Create done button for keyboard
- (void)setCloseKeyboardAccessoryForSender:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UIToolbar * topView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.window.frame.size.width, 35)];
    [topView setBarStyle:UIBarStyleDefault];
    UIBarButtonItem* spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                     target:self
                                                                                     action:nil];
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                    target:self
                                                                                    action:@selector(editFinish)];
    doneButtonItem.tintColor = [UIColor colorWithRed:38/255.0 green:186/255.0 blue:152/255.0 alpha:1.0];
    NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButtonItem, doneButtonItem, nil];
    [topView setItems:buttonsArray];
    [sender setInputAccessoryView:topView];
}

- (void)editFinish {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([_thresholdTextField isFirstResponder]) {
        [_thresholdTextField resignFirstResponder];
    }
}

#pragma mark - Key Value Observe
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (DEBUG) {
        NSLog(@"Running %@ '%@', keyPath is %@", self.class, NSStringFromSelector(_cmd), keyPath);
    }
    if ([keyPath isEqualToString:@"setOwner"]) {
        if (DEBUG) {
            NSLog(@"Send owner's information to %ld untrusted servers successfully.", (long)self.setOwner);
        }
        //Send owner's information to all untrusted servers successfully.
        if (self.setOwner == group.defaults.servers.count) {
            if (DEBUG) {
                NSLog(@"Send owner's information to all untrusted servers successfully!");
            }
            [self removeObserver:self forKeyPath:@"setOwner"];
            //Send init message to untrusted servers.
            [self submitServerCountAndThreshold];
        }
    } else if ([keyPath isEqualToString:@"setThreshold"]) {
        if (DEBUG) {
            NSLog(@"Send init message to %ld untrusted servers successfully.", (long)self.setThreshold);
        }
        if (self.setThreshold == group.defaults.servers.count) {
            if (DEBUG) {
                NSLog(@"Send init message to all untrusted servers successfully!");
            }
            [self removeObserver:self forKeyPath:@"setThreshold"];
            
            //Set threshold, owner and update number of group memebers
            group.defaults.serverCount = group.defaults.servers.allKeys.count;
            group.defaults.threshold = _thresholdTextField.text.integerValue;
            group.defaults.owner = user.userId;
            group.defaults.members ++;
            //Hide initial group button and add server bar button
            _initialGroupButton.hidden = YES;
            _addServerBarButtonItem.enabled = NO;
            //Change initial state.
            group.defaults.initial = InitialFinished;
            
            _thresholdTextField.text = [NSString stringWithFormat:@"Threshold is %ld", (long)group.defaults.threshold];
            [_thresholdTextField setEnabled:NO];
            
            [AlertTool showAlertWithTitle:@"Tip"
                               andContent:[NSString stringWithFormat:@"%@ has been initialized successfully!", group.defaults.groupName]
                         inViewController:self];
        }
    }
}

@end
