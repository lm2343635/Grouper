//
//  ClassificationDao.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "ClassificationDao.h"

@implementation ClassificationDao

- (NSManagedObjectID *)saveWithName:(NSString *)cname
                      inAccountBook:(AccountBook *)accountBook {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Classification *classification=[NSEntityDescription insertNewObjectForEntityForName:ClassificationEntityName
                                                                 inManagedObjectContext:self.context];
    classification.cname=cname;
    classification.accountBook=accountBook;
    [self saveContext];
    return classification.objectID;
}

- (NSArray *)findWithAccountBook:(AccountBook *)accountBook {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"accountBook=%@", accountBook];
    return [self findByPredicate:predicate withEntityName:ClassificationEntityName];
}
@end
