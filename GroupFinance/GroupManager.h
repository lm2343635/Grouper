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
@property (nonatomic, strong) NSMutableArray *members;
@property (nonatomic, strong) NSMutableDictionary *membersDict;

typedef void (^MemberRefreshCompletion)(BOOL);

// Get single instance.
+ (instancetype)sharedInstance;

// Refresh member list.
- (void)refreshMemberListWithCompletion:(MemberRefreshCompletion)completion;

@end
