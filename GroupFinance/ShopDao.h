//
//  ShopDap.h
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "DaoTemplate.h"

#define ShopEntityName @"Shop"

@interface ShopDao : DaoTemplate

- (NSManagedObjectID *)saveWithName:(NSString *)sname;

- (NSArray *)findAll;

@end
