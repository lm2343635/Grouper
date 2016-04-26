//
//  AccountBook.m
//  GroupFinance
//
//  Created by lidaye on 4/26/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AccountBook.h"

@implementation AccountBook

// Insert code here to add functionality to your managed object subclass

- (void)awakeFromInsert {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super awakeFromInsert];
    if(!self.uniqueIdentifier) {
        self.uniqueIdentifier=[[NSUUID UUID] UUIDString];
    }
}

+ (instancetype)saveWithName:(NSString *)abname
              inMangedObjectContext:(NSManagedObjectContext *)context {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    AccountBook *accountBook=[NSEntityDescription insertNewObjectForEntityForName:@"AccountBook"
                                                           inManagedObjectContext:context];
    accountBook.abname=abname;
    [context save:nil];
    return accountBook;
}

+ (NSArray *)findAllinMangedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AccountBook" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    NSArray *accountBooks = [context executeFetchRequest:fetchRequest error:&error];
    if(error) {
        NSLog(@"%@", error.localizedDescription);
    }
    return accountBooks;
}

@end
