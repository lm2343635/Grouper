//
//  MembersManager.h
//  GroupFinance
//
//  Created by lidaye on 31/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Defaults.h"

@interface GroupManager : NSObject

@property (nonatomic, strong) Defaults *defaults;

// Members array.
@property (nonatomic, strong) NSMutableArray *members;

// Members dictionary, key is userId, value is member object.
@property (nonatomic, strong) NSMutableDictionary *membersDict;

typedef void (^MemberRefreshCompletion)(BOOL);
typedef void (^CheckServerCompletion)(NSDictionary *, BOOL);
typedef void (^AddNewServerCompletion)(BOOL, NSString *);

// Get single instance.
+ (instancetype)sharedInstance;

// Refresh member list.
- (void)refreshMemberListWithCompletion:(MemberRefreshCompletion)completion;

// Check server state, if the number of connected servers is larger than or equals to the threshold, sync with untrusted servers.
- (void)checkServerState:(CheckServerCompletion)completion;

- (void)addNewServer:(NSString *)address
       withGroupName:(NSString *)groupName
          andGroupId:(NSString *)groupId
          completion:(AddNewServerCompletion)completion;

@end
