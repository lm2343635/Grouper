//
//  TemplateDao.m
//  GroupFinance
//
//  Created by lidaye on 6/5/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "TemplateDao.h"

@implementation TemplateDao

- (Template *)saveWithNname:(NSString *)tname
                       andRecordType:(NSNumber *)recordType
                   andClassification:(Classification *)classification
                          andAccount:(Account *)account
                             andShop:(Shop *)shop
                             creator:(NSString *)creator {
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
    
    template.creator = creator;
    template.update = creator;
    [self saveContext];
    return template;
}

- (NSArray *)findAll {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"tname" ascending:NO];
    return [self findByPredicate:nil withEntityName:TemplateEntityName orderBy:sort];
}

@end
