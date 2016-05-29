//
//  ShopDap.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "ShopDao.h"

@implementation ShopDao

- (NSManagedObjectID *)saveWithName:(NSString *)sname inAccountBook:(AccountBook *)accountBook {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Shop *shop=[NSEntityDescription insertNewObjectForEntityForName:ShopEntityName
                                             inManagedObjectContext:self.context];
    shop.sname=sname;
    shop.accountBook=accountBook;
    [self saveContext];
    return shop.objectID;
}

- (NSArray *)findWithAccountBook:(AccountBook *)accountBook {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"accountBook=%@", accountBook];
    return [self findByPredicate:predicate withEntityName:ShopEntityName];
}

@end
