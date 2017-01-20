//
//  AccountDao.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AccountDao.h"

@implementation AccountDao

- (Account *)saveWithName:(NSString *)aname creator:(NSString *)creator {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Account *account = [NSEntityDescription insertNewObjectForEntityForName:AccountEntityName
                                                     inManagedObjectContext:self.context];
    account.aname = aname;
    account.creator = creator;
    account.updater = creator;
    [self saveContext];
    return account;
}

- (NSArray *)findAll {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"aname" ascending:NO];
    return [self findByPredicate:nil withEntityName:AccountEntityName orderBy:sort];
}

@end
