//
//  MembersManager.m
//  GroupFinance
//
//  Created by lidaye on 31/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "GroupManager.h"
#import "GroupTool.h"
#import "DaoManager.h"
#import "InternetTool.h"

@implementation GroupManager {
    GroupTool *group;
    DaoManager *dao;
    NSDictionary *managers;
    User *currentUser;
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
        managers = [InternetTool getSessionManagers];
        group = [GroupTool sharedInstance];
        dao = [DaoManager sharedInstance];
        currentUser = [dao.userDao currentUser];
        [self updateMember];
    }
    return self;
}

- (void)refreshMemberListWithCompletion:(MemberRefreshCompletion)completion {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (group.initial != InitialFinished) {
        completion(NO);
        return;
    }
    NSString *address0 = [group.servers.allKeys objectAtIndex:0];
    //Reload user info
    [managers[address0] GET:[InternetTool createUrl:@"user/list" withServerAddress:address0]
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
                            group.members = users.count;
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

@end
