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

// Save a existed message from other devices.
- (Message *)saveWithMessageData:(MessageData *)messageData;

// Create a new messsage by the device itself.
- (Message *)saveWithContent:(NSString *)content
                  objectName:(NSString *)objectName
                    objectId:(NSString *)objectId
                        type:(NSString *)type
                        from:(NSString *)sender
                          to:(NSString *)receiver
                    sequence:(long)sequence
                       email:(NSString *)email
                        name:(NSString *)name;

// Find all message.
- (NSArray *)findAll;

// Find all normal message.
- (NSArray *)findNormal;

// Find all control message;
- (NSArray *)findControl;

// Find normal messages sent by a sender(userId).
- (NSArray *)findNormalWithSender:(NSString *)sender;

// Find messages in a sequences array with node identifier.
- (NSArray *)findInSequences:(NSArray *)sequences withNode:(NSString *)node;

// Find sequences in a sequences array with node identifier.
- (NSArray *)findExistedSequencesIn:(NSArray *)sequences withNode:(NSString *)node;

@end
