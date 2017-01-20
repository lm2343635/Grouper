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

- (Account *)saveWithName:(NSString *)aname creator:(NSString *)creator;

- (NSArray *)findAll;

@end
