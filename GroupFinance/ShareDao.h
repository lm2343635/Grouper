//
//  ShareDao.h
//  GroupFinance
//
//  Created by lidaye on 27/03/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "DaoTemplate.h"

#define ShareEntityName @"Share"

@interface ShareDao : DaoTemplate

- (Share *)saveWithShareId:(NSString *)shareId;

- (NSArray *)findInShareIds:(NSArray *)shareIds;

- (BOOL)deleteAll;

@end
