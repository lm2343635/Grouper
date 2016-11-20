//
//  TemplateDao.m
//  GroupFinance
//
//  Created by lidaye on 6/5/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "TemplateDao.h"

@implementation TemplateDao

- (NSManagedObjectID *)saveWithNname:(NSString *)tname
                       andRecordType:(NSNumber *)recordType
                   andClassification:(Classification *)classification
                          andAccount:(Account *)account
                             andShop:(Shop *)shop {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Template *template = [NSEntityDescription insertNewObjectForEntityForName:TemplateEntityName
                                                       inManagedObjectContext:self.context];
    template.tname = tname;
    template.saveRecordType = recordType;
    template.classification = classification;
    template.account = account;
    template.shop = shop;
    [self saveContext];
    return template.objectID;
}

- (NSArray *)findAll {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"tname" ascending:NO];
    return [self findByPredicate:nil withEntityName:TemplateEntityName orderBy:sort];
}

@end
