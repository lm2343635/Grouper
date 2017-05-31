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

// Save user info.
- (User *)saveWithEmail:(NSString *)email
                forName:(NSString *)name
                 inNode:(NSString *)node;

// Update user's info.
- (User *)updateName:(NSString *)name
                node:(NSString *)node
             byEmail:(NSString *)email;

- (User *)getByEmail:(NSString *)email;

// Find all members except owner.
- (NSArray *)findMembersExceptOwner:(NSString *)ownerId;

// Find all members.
- (NSArray *)findAll;

@end
