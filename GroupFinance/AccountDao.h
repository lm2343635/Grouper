//
//  AccountDao.h
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "DaoTemplate.h"

#define AccountEntityName @"Account"

@interface AccountDao : DaoTemplate

- (NSManagedObjectID *)saveWithName:(NSString *)aname;

- (NSArray *)findAll;

@end
