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

// Save user info from facebook.
- (User *)saveFromFacebook:(id)object;

// Save other user's info from ustrusted servers.
- (User *)saveOrUpdate:(NSObject *)object;

- (User *)getByUserId:(NSString *)userId;

- (User *)currentUser;

- (NSArray *)findMembersExceptOwner:(NSString *)ownerId;

@end
