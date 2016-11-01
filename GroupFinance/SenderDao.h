//
//  SenderDao.h
//  GroupFinance
//
//  Created by 李大爷的电脑 on 01/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "DaoTemplate.h"
#import <SYNCPropertyMapper/NSManagedObject+SYNCPropertyMapper.h>

#define RecordEntityName @"Sender"

@interface SenderDao : DaoTemplate

- (Sender *)saveWithObject:(NSManagedObject *)object;

@end