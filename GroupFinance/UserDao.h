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

- (NSManagedObjectID *)saveWithJSONObject:(NSObject *)object;

- (User *)getByUserId:(NSString *)userId;

- (User *)getUsingUser;

@end
