//
//  RecordDao.m
//  GroupFinance
//
//  Created by lidaye on 5/29/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "RecordDao.h"

@implementation RecordDao

 -(NSManagedObjectID *)saveWithMoney:(NSNumber *)money
                           andRemark:(NSString *)remark
                             andTime:(NSDate *)time
                   andClassification:(Classification *)classsification
                          andAccount:(Account *)account
                             andShop:(Shop *)shop
                            andPhoto:(Photo *)photo {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    Record *record = [NSEntityDescription insertNewObjectForEntityForName:RecordEntityName
                                                 inManagedObjectContext:self.context];
    record.money = money;
    record.remark = remark;
    record.time = time;
    record.classification = classsification;
    record.account = account;
    record.shop = shop;
    record.photo = photo;

    [self saveContext];
    return record.objectID;
}

- (NSArray *)findAll {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
    return [self findByPredicate:nil withEntityName:RecordEntityName orderBy:sort];
}

@end
