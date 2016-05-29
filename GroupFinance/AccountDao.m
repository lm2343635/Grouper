//
//  AccountDao.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AccountDao.h"

@implementation AccountDao

- (NSManagedObjectID *)saveWithName:(NSString *)aname inAccountBook:(AccountBook *)accountBook {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Account *account=[NSEntityDescription insertNewObjectForEntityForName:AccountEntityName
                                                   inManagedObjectContext:self.context];
    account.aname=aname;
    account.accountBook=accountBook;
    [self saveContext];
    return account.objectID;
}

- (NSArray *)findWithAccountBook:(AccountBook *)accountBook {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"accountBook=%@", accountBook];
    return [self findByPredicate:predicate withEntityName:AccountEntityName];
}

@end
