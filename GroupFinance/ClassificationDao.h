//
//  ClassificationDao.h
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "DaoTemplate.h"

#define ClassificationEntityName @"Classification"

@interface ClassificationDao : DaoTemplate

- (NSManagedObjectID *)saveWithName:(NSString *)cname inAccountBook:(AccountBook *)accountBook;

- (NSArray *)findWithAccountBook:(AccountBook *)accountBook;

@end
