//
//  MembersManager.m
//  GroupFinance
//
//  Created by lidaye on 31/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "GroupManager.h"
#import "NetManager.h"
#import "DEBUG.h"

@implementation GroupManager {
    CoreDaoManager *dao;
    
    NetManager *net;
    
    // Invite new member related.
    MultipeerConnectivityManager *multipeerConnectivity;
    NSMutableDictionary *serverInfoForUser;
    
    // Check server state related.
    int accessed, checked;
    NSMutableDictionary *serverStates;
    MCPeerID *invitePeer;
    
    // Joiner's user info.
    NSDictionary *joiner;
    
    // Register owner related.
    int registered, submitted;
}

+ (instancetype)sharedInstance {
    static GroupManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GroupManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        net = [NetManager sharedInstance];
        dao = [CoreDaoManager sharedInstance];
        
        _defaults = [Defaults sharedInstance];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(peerDidChangeStateWithNotification:)
                                                     name:MCDidChangeStateNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveDataWithNotification:)
                                                     name:MCDidReceiveDataNotification
                                                   object:nil];
        
        // Set up current user and multipeer connectivity related variables.
        _currentUser = [dao.userDao getByEmail:_defaults.me];
    }
    return self;
}

#pragma mark - App Data Stack
- (void)saveAppContext {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    if ([_appDataStack.mainContext hasChanges]) {
        NSError *error = nil;
        if([_appDataStack.mainContext save:&error]) {
            if(DEBUG)
                NSLog(@"_context saved changes to persistent store.");
        } else {
            NSLog(@"Failed to save _context : %@",error);
        }
    } else {
        NSLog(@"Skipped _context save, there are no changes.");
    }
}

#pragma mark - User

- (void)saveCurrentUserWithEmail:(NSString *)email name:(NSString *)name {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // If current user is existed, delete it at first.
    if (_defaults.me != nil) {
        User *user = [dao.userDao getByEmail:_defaults.me];
        [dao.context deleteObject:user];
    }
    
    _currentUser = [dao.userDao saveWithEmail:email
                                      forName:name
                                       inNode:_defaults.node];
    _defaults.me = email;
    // Setup multipeer connectivity related variables.
    [self setupMutipeerConnectivity];
}

- (void)setupMutipeerConnectivity {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (_currentUser == nil) {
        return;
    }
    // Init multipeerConnectivity manager.
    multipeerConnectivity = [[MultipeerConnectivityManager alloc] initWithAppId:_appId];
    // Set device's display name by current user's name.
    [multipeerConnectivity setupPeerAndSessionWithDisplayName:_currentUser.name];
    [multipeerConnectivity advertiseSelf:YES];

    _connectedPeers = [[NSMutableArray alloc] init];
    _isOwner = [_defaults.owner isEqualToString:_currentUser.email];
}

- (User *)getUserByNodeIdentifier:(NSString *)node {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [dao.userDao getByNode:node];
}

#pragma mark - Invite Member

- (void)openDeviceBroswerIn:(UIViewController *)controller {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [multipeerConnectivity setupMCBrowser];
    [multipeerConnectivity.browserViewController setDelegate:self];
    [controller presentViewController:multipeerConnectivity.browserViewController animated:YES completion:nil];
}

- (void)sendInviteMessageTo:(MCPeerID *)peer {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // Save peer to global varibale invite peer.
    invitePeer = peer;
    // Send invite message.
    [self sendMessage:@{@"task": @"invite"} to:invitePeer];
}

- (void)sendMessage:(NSDictionary *)message to:(MCPeerID *)peer {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:message
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
    NSError *error;
    [multipeerConnectivity.session sendData:data
                                    toPeers:[NSArray arrayWithObject:peer]
                                   withMode:MCSessionSendDataReliable
                                      error:&error];
    if(error) {
        NSLog(@"Error in sending: %@", error.localizedDescription);
    }
}

#pragma mark - Notification 

- (void)peerDidChangeStateWithNotification:(NSNotification *)notification {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    MCPeerID *peerID = [notification.userInfo objectForKey:@"peerID"];
    MCSessionState state = [[notification.userInfo objectForKey:@"state"] intValue];

    if (state != MCSessionStateConnecting) {
        if (state == MCSessionStateConnected) {
            [_connectedPeers addObject:peerID];
        } else if (state == MCSessionStateNotConnected) {
            if (_connectedPeers.count > 0) {
                [_connectedPeers removeObject:peerID];
            }
        }
        // TODO: Update user interface.
        // You can use KVO in your UIViewController to update table using group.connectedPeers.
        // Or you can update in viewWillAppear: method.
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
    if ([task isEqualToString:@"invite"] && !_isOwner) {
        [self sendMessage:@{
                            @"task": @"sendUserInfo",
                            @"userInfo": @{
                                    @"email": _currentUser.email,
                                    @"name": _currentUser.name,
                                    @"node": _currentUser.node
                                }
                            }
                       to:peerID];
    } else if ([task isEqualToString:@"sendUserInfo"] && _isOwner) {
        submitted = 0;
        // Get joiner's user info and confirm his email.
        joiner = [message valueForKey:@"userInfo"];
        // If this joiner's email is existed in owner's persistent store,
        // don't allow this joiner to join this group.
        if ([dao.userDao getByEmail:[joiner valueForKey:@"email"]] != nil) {
            [self sendMessage:@{
                                @"task": @"sendServerInfo",
                                @"existed": @YES,
                            }
                           to:invitePeer];
            // Send notification with failed message.
            [[NSNotificationCenter defaultCenter] postNotificationName:DidReceiveInviteFailedMessage
                                                                object:nil
                                                              userInfo:nil];
            return;
        }
        
        // The new joiner can be invited to this group, grouper owner register for him in multiple untrusted server.
        // Init serverInfoForUser
        serverInfoForUser = [[NSMutableDictionary alloc] init];
        // Send user info to untrusted servers.
        for (NSString *address in net.managers.allKeys) {
            [net.managers[address] POST:[NetManager createUrl:@"user/add" withServerAddress:address]
                             parameters:@{
                                          @"node": [joiner valueForKey:@"node"],
                                          @"owner": @NO
                                          }
                               progress:nil
                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                    InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                                    if ([response statusOK]) {
                                        NSObject *result = [response getResponseResult];
                                        NSString *accesskey = [result valueForKey:@"accesskey"];
                                        [serverInfoForUser setValue:accesskey forKey:address];
                                        NSLog(@"%@ serverInfoForUser %@", address, serverInfoForUser);
                                        // All task finished, submitted flag plus 1
                                        submitted ++;
                                        
                                        // Send owner's information to all untrusted servers successfully.
                                        if (submitted == _defaults.serverCount) {
                                            if (DEBUG) {
                                                NSLog(@"Send user's information to all untrusted servers successfully!");
                                                //Send access keys and server information to joiner.
                                                NSLog(@"serverInfoForUser = %@", serverInfoForUser);
                                                NSLog(@"invitePeer = %@", invitePeer);
                                            }
                                            
                                            // Prepare user list for joiner.
                                            NSMutableArray *users = [[NSMutableArray alloc] init];
                                            for (User *user in [dao.userDao findAll]) {
                                                [users addObject:@{
                                                                   @"email": user.email,
                                                                   @"name": user.name,
                                                                   @"node": user.node
                                                                   }];
                                            }
                                            
                                            // Send server information to new member.
                                            [self sendMessage:@{
                                                                @"task": @"sendServerInfo",
                                                                @"existed": @NO,
                                                                @"servers": serverInfoForUser,
                                                                @"users": users,
                                                                @"owner": _defaults.owner
                                                                }
                                                           to:invitePeer];
                                            
                                        }
                                    }
                                }
                                failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                    InternetResponse *response = [[InternetResponse alloc] initWithError:error];
                                    switch ([response errorCode]) {
                                        default:
                                            break;
                                    }
                                }];
        }
    } else if ([task isEqualToString:@"sendServerInfo"] && !_isOwner) {
        // If the new joiner is existed in owner's device,
        if ([[message valueForKey:@"existed"] boolValue]) {
            // Send notification with failed message.
            [[NSNotificationCenter defaultCenter] postNotificationName:DidReceiveInviteFailedMessage
                                                                object:nil
                                                              userInfo:nil];
            return;
        }
        
        // Receive servers and owner.
        _defaults.servers = [message valueForKey:@"servers"];
        _defaults.owner = [message valueForKey:@"owner"];
        
        // Save other group member's user info to persistent store.
        for (NSDictionary *user in [message valueForKey:@"users"]) {
            [dao.userDao saveWithEmail:[user valueForKey:@"email"]
                               forName:[user valueForKey:@"name"]
                                inNode:[user valueForKey:@"node"]];
        }
         
        // Refresh session managers.
        [net refreshSessionManagers];
        
        // Send joinSuccess messgae to group owner.
        [self sendMessage:@{@"task": @"joinSuccess"} to:peerID];
        
        //Download group members and group info from server 0.
        NSString *address0 = [net.managers.allKeys objectAtIndex:0];
        [net.managers[address0] GET:[NetManager createUrl:@"group/info" withServerAddress:address0]
                         parameters:nil
                           progress:nil
                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                                if ([response statusOK]) {
                                    NSObject *result = [response getResponseResult];
                                    NSObject *groupInfo = [result valueForKey:@"group"];
                                    // Update group information
                                    _defaults.groupId = [groupInfo valueForKey:@"id"];
                                    _defaults.groupName = [groupInfo valueForKey:@"name"];
                                    _defaults.members = [[groupInfo valueForKey:@"members"] integerValue];
                                    
                                    _defaults.serverCount = [[groupInfo valueForKey:@"servers"] integerValue];
                                    _defaults.threshold = [[groupInfo valueForKey:@"threshold"] integerValue];
                                    _defaults.interval = [[groupInfo valueForKey:@"interval"] integerValue];
                                    
                                    // Set initial state to InitialFinished
                                    _defaults.initial = InitialFinished;
                                    
                                    // Send notification with joined success message.
                                    [[NSNotificationCenter defaultCenter] postNotificationName:DidReceiveJoinGroupMessage
                                                                                        object:nil
                                                                                      userInfo:nil];
                                }
                            }
                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                InternetResponse *response = [[InternetResponse alloc] initWithError:error];
                                switch ([response errorCode]) {
                                        
                                }
                            }];

        
    } else if ([task isEqualToString:@"joinSuccess"] && _isOwner) {
        // Save joiner's user info to persistent store.
        [dao.userDao saveWithEmail:[joiner valueForKey:@"email"]
                           forName:[joiner valueForKey:@"name"]
                            inNode:[joiner valueForKey:@"node"]];
        
        // Joined group successfully. Add this user to user list.
        // Send notification with joined success message.
        [[NSNotificationCenter defaultCenter] postNotificationName:DidReceiveInviteSuccessMessage
                                                            object:nil
                                                          userInfo:@{@"joiner": invitePeer.displayName}];
    }
}

#pragma mark - MCBrowserViewControllerDelegate
-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [multipeerConnectivity.browserViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [multipeerConnectivity.browserViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Group Init Related
    
- (void)addNewServer:(NSString *)address
       withGroupName:(NSString *)groupName
          andGroupId:(NSString *)groupId
          completion:(SucessMessageCompletion)completion {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // Dont allow user to add new untrusted server when he is restoring existed untrusted servers.
    if (_defaults.initial == RestoringServer) {
        completion(NO, @"Cannot add new untrusted server when you are restoring existed untrusted servers");
        return;
    }
    // Check address, groupName and groupId is empty or not.
    if ([groupId isEqualToString:@""] || [groupName isEqualToString:@""] || [address isEqualToString:@""]) {
        completion(NO, @"Group id, group name and server address cannot be empty!");
        return;
    }
    // Check the server address is existed in servers dictionary or not.
    for (NSString *exist in _defaults.servers.allKeys) {
        if ([address isEqualToString:exist]) {
            completion(NO, @"This server address is exist!");
            return;
        }
    }
    [net.manager POST:[NSString stringWithFormat:@"http://%@/group/register", address]
           parameters:@{
                        @"id": groupId,
                        @"name": groupName
                        }
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                  if ([response statusOK]) {
                      NSObject *result = [response getResponseResult];
                      // Save group's master key.
                      [_defaults addServerAddress:address
                                    withAccessKey:[result valueForKey:@"masterkey"]];
                      // Set group id and group name if group state is NotInitial.
                      if (_defaults.initial == NotInitial) {
                          _defaults.groupId = groupId;
                          _defaults.groupName = groupName;
                          _defaults.initial = AddingNewServer;
                      }
                      completion(YES, nil);
                  }
              }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  InternetResponse *response = [[InternetResponse alloc] initWithError:error];
                  switch ([response errorCode]) {
                      case ErrorNotConnectedToInternet:
                          completion(NO, @"Cannot find this server!");
                          break;
                      case ErrorGroupExsit:
                          completion(NO, @"Group id has been registered by other users in this server!");
                          break;
                      case ErrorGroupRegister:
                          completion(NO, @"Register group error, try again later.");
                          break;
                      default:
                          break;
                  }
              }];
}

- (void)restoreExistedServer:(NSString *)address
                 byAccessKey:(NSString *)key
                  completion:(SucessMessageCompletion)completion {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // Dont allow user to restore an existed untrusted server when he is adding new untrusted servers.
    if (_defaults.initial == AddingNewServer) {
        completion(NO, @"Cannot restore an existed untrusted server when you are adding new untrusted servers.");
        return;
    }
    // Check address and access key is empty or not.
    if ([address isEqualToString:@""] || [key isEqualToString:@""]) {
        completion(NO, @"Server address and access key cannot be empty!");
        return;
    }
    // Check the server address is existed in servers dictionary or not.
    for (NSString *exist in _defaults.servers.allKeys) {
        if ([address isEqualToString:exist]) {
            completion(NO, @"This server is existed!");
            return;
        }
    }
    
    [net.manager POST:[NSString stringWithFormat:@"http://%@/group/restore", address]
           parameters:@{
                        // TODO List
//                        @"userId": _currentUser.userId,
                        @"accesskey": key
                        }
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                  if ([response statusOK]) {
                      NSObject *result = [response getResponseResult];
     
                      // Add server address and access key to servers dictionary.
                      [_defaults addServerAddress:address withAccessKey:key];
                      
                      // Restore group info.
                      if (_defaults.initial == NotInitial) {
                           NSObject *groupInfo = [result valueForKey:@"group"];
                          _defaults.groupId = [groupInfo valueForKey:@"id"];
                          _defaults.groupName = [groupInfo valueForKey:@"name"];
                          _defaults.members = [[groupInfo valueForKey:@"members"] integerValue];
                          _defaults.owner = [groupInfo valueForKey:@"oid"];
                          _defaults.serverCount = [[groupInfo valueForKey:@"servers"] integerValue];
                          _defaults.threshold = [[groupInfo valueForKey:@"threshold"] integerValue];
                          _defaults.initial = RestoringServer;
                      }
                      
                      // Restore this server successfully.
                      completion(YES, nil);
                  }
              }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  InternetResponse *response = [[InternetResponse alloc] initWithError:error];
                  switch ([response errorCode]) {
                      case ErrorNotConnectedToInternet:
                          completion(NO, @"Cannot find this server!");
                          break;
                      case ErrorAccessKey:
                          completion(NO, @"Access key is not found in this server.");
                          break;
                      case ErrorUserNotMatch:
                          completion(NO, @"This access key is not your access key, or you are not member of the group.");
                          break;
                      default:
                          break;
                  }
              }];
}

- (void)initializeGroup:(int)threshold
               interval:(int)interval
         withCompletion:(SucessMessageCompletion)completion {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    //Validate threshold when user wants to create a new group.
    //Threshold need not to validate when user wants to restore an existed group.
    if (_defaults.initial == AddingNewServer) {
        if (threshold < 1 || threshold > _defaults.servers.allKeys.count) {
            completion(NO, @"Recover threshold be more than 0 and less than the number of servers.");
            return;
        }
        //Refresh session manager.
        [net refreshSessionManagers];
        // Register owner in untrusted servers.
        registered = 0;

        // Submit owner's user information to multiple untrusted servers.
        for (NSString *address in net.managers.allKeys) {
            [net.managers[address] POST:[NetManager createUrl:@"user/add" withServerAddress:address]
                             parameters:@{
                                          @"node": _currentUser.node,
                                          @"owner": @YES
                                          }
                               progress:nil
                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                    InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                                    if ([response statusOK]) {
                                        registered ++;
                                    }
                                    
                                    // If the number registered servers equals to the count of servers dictionary, submit server count and threshold.
                                    // DO NOT USER _defaults.serverCount DIRECTLY!!!!!!!! It has not be set before submit server count to untrusted server.
                                    // Use _defaults.servers.allKeys.count here.
                                    if (registered == _defaults.servers.allKeys.count) {
                                        [self submitServerThreshold:threshold
                                                           interval:interval
                                                     withCompletion:completion];
                                    }
                                }
                                failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                    InternetResponse *response = [[InternetResponse alloc] initWithError:error];
                                    switch ([response errorCode]) {
                                        case ErrorMasterKey:
                                            completion(NO, @"Your master key is wrong!");
                                            break;
                                        case ErrorAddUser:
                                            completion(NO, @"Add owner failed in server, try again later.");
                                            break;
                                        default:
                                            break;
                                    }
                                }];
        }
    }
    // Check the number of untrusted servers if user wants to initialize by restoring an existed group.
    else if (_defaults.initial == RestoringServer) {
        if (_defaults.servers.allKeys.count != _defaults.serverCount) {
            completion(NO, [NSString stringWithFormat:@"%ld servers are necessary to initialize your group when you are restoring existed untrusted servers.", (long)_defaults.serverCount]);
            return;
        }
        //Change initial state.
        _defaults.initial = InitialFinished;
        // Initialize successfully!!!
        completion(YES, [NSString stringWithFormat:@"%@ has been initialized successfully!", _defaults.groupName]);
    }
    
}

// Submit server count and threshold to multiple unstruste servers.
- (void)submitServerThreshold:(int)threshold
                     interval:(int)interval
               withCompletion:(SucessMessageCompletion)completion {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // Set the number of submitted servers to 0.
    submitted = 0;
    
    // Submit server count and threshold to multiple untrusted servers by group/init API.
    for (NSString *address in net.managers.allKeys) {
        [net.managers[address] POST:[NetManager createUrl:@"group/init" withServerAddress:address]
                         parameters:@{
                                      // User _defaults.servers.allKeys.count here RATHER THAN _defaults.serverCount, because group has not been initialized successfully.
                                      @"servers": [NSNumber numberWithInteger:_defaults.servers.allKeys.count],
                                      @"threshold": [NSNumber numberWithInt:threshold],
                                      @"interval": [NSNumber numberWithInt:interval]
                                      }
                           progress:nil
                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                                if ([response statusOK]) {
                                    // If submit successfully, the number of submitted servers plus 1.
                                    submitted ++;
                                }
                                
                                // If the number of submitted servers equals to the count of servers dictionary,
                                // save server count, threshold, userId of owner, number of members to NSUserDefaults.
                                if (submitted == _defaults.servers.allKeys.count) {
                                    //Set threshold, owner and update number of group memebers
                                    _defaults.serverCount = _defaults.servers.allKeys.count;
                                    _defaults.threshold = threshold;
                                    _defaults.interval = interval;
                                    _defaults.owner = _currentUser.email;
                                    _defaults.members ++;

                                    //Change initial state.
                                    _defaults.initial = InitialFinished;

                                    // Initialize successfully!!!
                                    completion(YES, [NSString stringWithFormat:@"%@ has been initialized successfully!", _defaults.groupName]);
                                }
                            }
                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                InternetResponse *response = [[InternetResponse alloc] initWithError:error];
                                switch ([response errorCode]) {
                                    default:
                                        completion(NO, nil);
                                        break;
                                }
                            }];
    }
}

- (BOOL)isInitialized {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return _defaults.initial == InitialFinished;
}

#pragma mark - Synchronization Related.

- (void)checkServerState:(CheckServerCompletion)completion {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    checked = accessed = 0;
    serverStates = [[NSMutableDictionary alloc] init];
    for (NSString *address in net.managers.allKeys) {
        [net.managers[address] GET:[NetManager createUrl:@"user/state" withServerAddress:address]
                        parameters:nil
                          progress:nil
                           success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                               InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                               if ([response statusOK]) {
                                   BOOL state = [[[response getResponseResult] valueForKey:@"ok"] boolValue];
                                   if (state) {
                                       accessed ++;
                                   }
                         
                                   [serverStates setValue:[NSNumber numberWithBool:state] forKey:address];
                                   checked ++;
                                   [self checkComplete:completion];
                               }
                           }
                           failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                               //                               [self showState:NO forServer:address];
                               [serverStates setValue:[NSNumber numberWithBool:NO] forKey:address];
                               checked ++;
                               [self checkComplete:completion];
                           }];
        
    }
}

- (void)checkComplete:(CheckServerCompletion)completion {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (checked == _defaults.serverCount) {
        if (DEBUG) {
            NSLog(@"Grouper access to %d untrusted servers.", accessed);
        }
        // If threshold is k in a secret sharing scheme f(k, n),
        // sync method can be invoked after accessing more than k untrusted servers.
        completion(serverStates, (accessed >= _defaults.threshold) && (_defaults.initial == InitialFinished));
    }
}

- (void)clearShareId {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [dao.shareDao deleteAll];
}

#pragma mark - Device Token Related
- (void)sendDeviceToken:(NSString *)token {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (token == nil || [token isEqualToString:@""]) {
        return;
    }
    NSArray *addresses = net.managers.allKeys;
    for (int i = 0; i < _defaults.serverCount; i++) {
        NSString *address = addresses[i];
        [net.managers[address] POST:[NetManager createUrl:@"user/deviceToken" withServerAddress:address]
                         parameters:@{@"deviceToken": token}
                           progress:nil
                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                                if ([response statusOK]) {
                                    NSObject *result = [response getResponseResult];
                                    if ([[result valueForKey:@"success"] intValue] == 1) {
                                        if (DEBUG) {
                                            NSLog(@"Send device token to untrusted server %@", address);
                                        }
                                    }
                                }
                            }
                            failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                InternetResponse *response = [[InternetResponse alloc] initWithError:error];
                                switch ([response errorCode]) {
                                    case ErrorAccessKey:
                                        
                                        break;
                                    default:
                                        break;
                                }
                            }];
    }
    
}

@end
