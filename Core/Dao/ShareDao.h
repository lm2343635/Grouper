//
//  ShareDao.h
//  GroupFinance
//
//  Created by lidaye on 27/03/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "CoreDaoTemplate.h"

#define ShareEntityName @"Share"

@interface ShareDao : CoreDaoTemplate

- (Share *)saveWithShareId:(NSString *)shareId;

- (NSArray *)findInShareIds:(NSArray *)shareIds;

- (BOOL)deleteAll;

@end
