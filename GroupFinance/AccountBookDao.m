//
//  AccountBookDao.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AccountBookDao.h"

@implementation AccountBookDao

- (NSManagedObjectID *)saveWithName:(NSString *)abname forOwner:(NSString *)userId {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    AccountBook *accountBook = [NSEntityDescription insertNewObjectForEntityForName:AccountBookEntityName
                                                           inManagedObjectContext:self.context];
    accountBook.abname = abname;
    accountBook.owner = userId;
    [self saveContext];
    return accountBook.objectID;
}

- (AccountBook *)getUsingAccountBook {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *uniqueIdentifier = [defaults objectForKey:@"usingAccountBookIdentifier"];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"uniqueIdentifier=%@", uniqueIdentifier];
    return (AccountBook *)[self getByPredicate:predicate withEntityName:AccountBookEntityName];
}

- (void)setUsingAccountBook:(AccountBook *)accountBook {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //Save the unique identifier of using account book to sandbox.
    [defaults setObject:accountBook.uniqueIdentifier forKey:@"usingAccountBookIdentifier"];
    [self saveContext];
}
@end
