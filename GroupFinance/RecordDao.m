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

    //更新账户、分类和商家的资金流入流出
    if (money.intValue > 0) {
        record.classification.cin = [NSNumber numberWithInt:record.classification.cin.intValue+money.intValue];
        record.account.ain = [NSNumber numberWithInt:record.account.ain.intValue+money.intValue];
        record.shop.sin = [NSNumber numberWithInt:record.shop.sin.intValue+money.intValue];
    } else {
        record.classification.cout = [NSNumber numberWithInt:record.classification.cout.intValue-money.intValue];
        record.account.aout = [NSNumber numberWithInt:record.account.aout.intValue-money.intValue];
        record.shop.sout = [NSNumber numberWithInt:record.shop.sout.intValue-money.intValue];
    }
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
