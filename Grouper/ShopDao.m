//
//  ShopDap.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "ShopDao.h"

@implementation ShopDao

- (Shop *)saveWithName:(NSString *)sname creator:(NSString *)creator {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Shop *shop = [NSEntityDescription insertNewObjectForEntityForName:ShopEntityName
                                               inManagedObjectContext:self.context];
    shop.sname = sname;
    shop.creator = creator;
    shop.update = creator;
    [self saveContext];
    return shop;
}

- (NSArray *)findAll {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"sname" ascending:NO];
    return [self findByPredicate:nil withEntityName:ShopEntityName orderBy:sort];
}

@end
