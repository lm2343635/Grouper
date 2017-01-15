//
//  ReceiverDao.h
//  GroupFinance
//
//  Created by lidaye on 15/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "DaoTemplate.h"

#define ReceiverEntityName @"Receiver"

@interface ReceiverDao : DaoTemplate

- (Receiver *)saveWithShareId:(NSString *)shareId;

@end
