//
//  UserDao.h
//  GroupFinance
//
//  Created by lidaye on 04/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "CoreDaoTemplate.h"

#define UserEntityName @"User"

@interface UserDao : CoreDaoTemplate

// Save user info.
- (User *)saveWithEmail:(NSString *)email
                forName:(NSString *)name
                 inNode:(NSString *)node;

// Update user's info.
- (User *)updateName:(NSString *)name
                node:(NSString *)node
             byEmail:(NSString *)email;

- (User *)getByEmail:(NSString *)email;

- (User *)getByNode:(NSString *)node;

// Find all members except owner.
- (NSArray *)findMembersExceptOwner:(NSString *)ownerId;

// Find all members.
- (NSArray *)findAll;

@end
