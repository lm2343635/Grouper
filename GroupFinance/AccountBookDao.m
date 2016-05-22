//
//  AccountBookDao.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AccountBookDao.h"

@implementation AccountBookDao

- (NSManagedObjectID *)saveWithName:(NSString *)abname {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    AccountBook *accountBook=[NSEntityDescription insertNewObjectForEntityForName:AccountBookEntityName
                                                           inManagedObjectContext:self.context];
    accountBook.abname=abname;
    [self saveContext];
    return accountBook.objectID;
}

- (AccountBook *)getUsingAccountBook {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"using=%@", [NSNumber numberWithBool:YES]];
    return (AccountBook *)[self getByPredicate:predicate withEntityName:AccountBookEntityName];
}

- (void)setUsingAccountBook:(AccountBook *)accountBook {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    AccountBook *oldUsingAccountBook=[self getUsingAccountBook];
    oldUsingAccountBook.using=[NSNumber numberWithBool:NO];
    accountBook.using=[NSNumber numberWithBool:YES];
    [self saveContext];
}
@end
