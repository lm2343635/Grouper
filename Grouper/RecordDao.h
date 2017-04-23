//
//  RecordDao.h
//  GroupFinance
//
//  Created by lidaye on 5/29/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "DaoTemplate.h"

#define RecordEntityName @"Record"

@interface RecordDao : DaoTemplate

- (Record *)saveWithMoney:(NSNumber *)money
                andRemark:(NSString *)remark
                  andTime:(NSDate *)time
        andClassification:(Classification *)classsification
               andAccount:(Account *)account
                  andShop:(Shop *)shop
                 andPhoto:(Photo *)photo
                  creator:(NSString *)creator;

- (NSArray *)findAll;

@end
