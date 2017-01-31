//
//  MembersManager.h
//  GroupFinance
//
//  Created by lidaye on 31/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MembersManager : NSObject

typedef void (^MemberRefreshCompletion)(BOOL);

+ (instancetype)sharedInstance;

- (void)refreshMemberListWithCompletion:(MemberRefreshCompletion)completion;

@end
