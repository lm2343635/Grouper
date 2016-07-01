//
//  UserDao.h
//  GroupFinance
//
//  Created by lidaye on 7/1/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "DaoTemplate.h"

#define UserEntityName @"User"

@interface UserDao : DaoTemplate

- (NSManagedObjectID *)saveWithToken:(NSString *)token
                              andUid:(NSString *)uid;

- (User *)getByToken:(NSString *)token;

- (User *)getUsingUser;

@end
