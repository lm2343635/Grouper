//
//  TemplateDao.h
//  GroupFinance
//
//  Created by lidaye on 6/5/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "DaoTemplate.h"

#define TemplateEntityName @"Template"

@interface TemplateDao : DaoTemplate

- (Template *)saveWithNname:(NSString *)tname
                       andRecordType:(NSNumber *)recordType
                   andClassification:(Classification *)classification
                          andAccount:(Account *)account
                             andShop:(Shop *)shop
                             creator:(NSString *)creator;

- (NSArray *)findAll;

@end
