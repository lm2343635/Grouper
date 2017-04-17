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
    
    int accessed, checked;
    NSMutableDictionary *serverStates;
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
