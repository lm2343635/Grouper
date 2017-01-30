//
//  SenderDao.h
//  GroupFinance
//
//  Created by 李大爷的电脑 on 01/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "DaoTemplate.h"

#define SenderEntityName @"Sender"

@interface SenderDao : DaoTemplate

- (Sender *)saveWithContent:(NSString *)content
                     object:(NSString *)objectName
                       type:(NSString *)type
                forReceiver:(NSString *)receiver;

- (NSArray *)findResend;

@end
