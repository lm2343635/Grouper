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
                             andShop:(Shop *)shop
                       inAccountBook:(AccountBook *)accountBook {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Template *template=[NSEntityDescription insertNewObjectForEntityForName:TemplateEntityName
                                                     inManagedObjectContext:self.context];
    template.tname=tname;
    template.saveRecordType=recordType;
    template.classification=classification;
    template.account=account;
    template.shop=shop;
    template.accountBook=accountBook;
    [self saveContext];
    return template.objectID;
}

- (NSArray *)findWithAccountBook:(AccountBook *)accountBook {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"accountBook=%@", accountBook];
    return [self findByPredicate:predicate withEntityName:TemplateEntityName];
}

@end
