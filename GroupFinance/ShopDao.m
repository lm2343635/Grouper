//
//  ShopDap.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "ShopDao.h"

@implementation ShopDao

- (NSManagedObjectID *)saveWithName:(NSString *)sname {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Shop *shop = [NSEntityDescription insertNewObjectForEntityForName:ShopEntityName
                                               inManagedObjectContext:self.context];
    shop.sname = sname;
    [self saveContext];
    return shop.objectID;
}

- (NSArray *)findAll {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"cname" ascending:NO];
    return [self findByPredicate:nil withEntityName:ShopEntityName orderBy:sort];
}

@end
