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

// Create a new messsage by the device itself.
- (Message *)saveWithContent:(NSString *)content
                  objectName:(NSString *)objectName
                    objectId:(NSString *)objectId
                        type:(NSString *)type
                        from:(NSString *)sender
                          to:(NSString *)receiver;

// Save a existed message from other devices.
- (Message *)saveWithMessageData:(MessageData *)messageData;

// Find all message.
- (NSArray *)findAll;

// Find all normal message.
- (NSArray *)findNormal;

// Find normal message sent by a sender(userId).
- (NSArray *)findNormalWithSender:(NSString *)sender;

- (NSArray *)findSendtimesIn:(NSArray *)sendtimes;

@end
