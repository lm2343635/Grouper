//
//  MembersManager.m
//  GroupFinance
//
//  Created by lidaye on 31/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "GroupManager.h"
#import "DaoManager.h"
#import "NetManager.h"
#import "ReceiveManager.h"

@implementation GroupManager {
    DaoManager *dao;
    NetManager *net;
    User *currentUser;
    
    // Check server state related.
    int accessed, checked;
    NSMutableDictionary *serverStates;
    
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
        dao = [DaoManager sharedInstance];
        currentUser = [dao.userDao currentUser];
        _defaults = [Defaults sharedInstance];
        [self updateMember];
    }
    return self;
}

- (void)refreshCurrentUser {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    currentUser = [dao.userDao currentUser];
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
                        @"userId": currentUser.userId,
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

- (void)initializeGroup:(int)threshold withCompletion:(SucessMessageCompletion)completion {
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
                                          @"userId": currentUser.userId,
                                          @"name": currentUser.name,
                                          @"email": currentUser.email,
                                          @"gender": currentUser.gender,
                                          @"pictureUrl": currentUser.pictureUrl,
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
                                        [self submitServerCountAndThreshold:threshold withCompletion:completion];
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
- (void)submitServerCountAndThreshold:(int)threshold withCompletion:(SucessMessageCompletion)completion {
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
                                      @"threshold": [NSNumber numberWithInt:threshold]
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
                                    _defaults.owner = currentUser.userId;
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

#pragma mark - Synchronization Related.

- (void)refreshMemberListWithCompletion:(MemberRefreshCompletion)completion {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (_defaults.initial != InitialFinished) {
        completion(NO);
        return;
    }
    NSString *address0 = [_defaults.servers.allKeys objectAtIndex:0];
    //Reload user info
    [net.managers[address0] GET:[NetManager createUrl:@"user/list" withServerAddress:address0]
                     parameters:nil
                       progress:nil
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                            if ([response statusOK]) {
                                NSObject *result = [response getResponseResult];
                                NSArray *users = [result valueForKey:@"users"];
                                for (NSObject *user in users) {
                                    if ([currentUser.userId isEqualToString:[user valueForKey:@"userId"]]) {
                                        continue;
                                    }
                                    [dao.userDao saveOrUpdate:user];
                                }
                                // Update number of group members.
                                _defaults.members = users.count;
                                // Update group members
                                [self updateMember];
                                completion(YES);
                            }
                        }
                        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                            InternetResponse *response = [[InternetResponse alloc] initWithError:error];
                            switch ([response errorCode]) {
                                case ErrorMasterOrAccessKey:
                                    completion(NO);
                                    break;
                                case ErrorNotConnectedToInternet:
                                    completion(NO);
                                    break;
                            }
                        }];
    
}

- (void)updateMember {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    _members = [NSMutableArray arrayWithArray:[dao.userDao findAll]];
    _membersDict = [[NSMutableDictionary alloc] init];
    for (User *member in _members) {
        [_membersDict setObject:member forKey:member.userId];
    }
}

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
                                   //                                   [self showState:state forServer:address];
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

@end
