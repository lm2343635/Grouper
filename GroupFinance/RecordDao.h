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

//iOS客户端新建收支记录使用，必须更新账户、分类和商家的资金流入流出，以及对账历史记录
- (NSManagedObjectID *)saveWithMoney:(NSNumber *)money
                          andRemark:(NSString *)remark
                            andTime:(NSDate *)time
                  andClassification:(Classification *)classsification
                         andAccount:(Account *)account
                            andShop:(Shop *)shop
                           andPhoto:(Photo *)photo
                      inAccountBook:(AccountBook *)accountBook;

- (NSArray *)findByAccountBook:(AccountBook *)accountBook;

@end
