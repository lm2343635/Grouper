//
//  MessageDao.h
//  GroupFinance
//
//  Created by lidaye on 27/03/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "DaoTemplate.h"
#import "MessageData.h"

#define MessageEntityName @"Message"

@interface MessageDao : DaoTemplate

- (Message *)saveWithMessageData:(MessageData *)messageData;

@end
