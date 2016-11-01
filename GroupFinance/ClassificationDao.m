//
//  ClassificationDao.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "ClassificationDao.h"

@implementation ClassificationDao

- (Classification *)saveWithName:(NSString *)cname {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Classification *classification = [NSEntityDescription insertNewObjectForEntityForName:ClassificationEntityName
                                                                   inManagedObjectContext:self.context];
    classification.cname = cname;
    [self saveContext];
    return classification;
}

- (NSArray *)findAll {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"cname" ascending:NO];
    return [self findByPredicate:nil withEntityName:ClassificationEntityName orderBy:sort];
}
@end
