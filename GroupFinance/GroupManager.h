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
typedef void (^SucessMessageCompletion)(BOOL, NSString *);

// Get single instance.
+ (instancetype)sharedInstance;

// Refresh current user if user info changes.
// Example: Current user is nil when the app is lunched at first, but current user will be inserted if user login.
- (void)refreshCurrentUser;

//************************ Group Init Related ************************
    
// Add a new untrusted server.
- (void)addNewServer:(NSString *)address
       withGroupName:(NSString *)groupName
          andGroupId:(NSString *)groupId
          completion:(SucessMessageCompletion)completion;

// Restore an existed untrusted server.
- (void)restoreExistedServer:(NSString *)address
                 byAccessKey:(NSString *)key
                  completion:(SucessMessageCompletion)completion;

// Initialize group.
- (void)initializeGroup:(int)threshold withCompletion:(SucessMessageCompletion)completion;;

//************************ Synchronization Related ************************

// Refresh member list.
- (void)refreshMemberListWithCompletion:(MemberRefreshCompletion)completion;

// Check server state, if the number of connected servers is larger than or equals to the threshold, sync with untrusted servers.
- (void)checkServerState:(CheckServerCompletion)completion;

@end
