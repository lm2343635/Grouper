//
//  UserDao.h
//  GroupFinance
//
//  Created by lidaye on 04/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "DaoTemplate.h"

#define UserEntityName @"User"

@interface UserDao : DaoTemplate

- (User *)saveOrUpdateWithJSONObject:(NSObject *)object fromUntrustedServer:(BOOL)source;

- (User *)getByUserId:(NSString *)userId;

- (User *)getUsingUser;

- (NSArray *)findMembersExceptOwner:(NSString *)ownerId;

@end
