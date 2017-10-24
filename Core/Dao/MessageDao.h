//
//  MessageDao.h
//  GroupFinance
//
//  Created by lidaye on 27/03/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "CoreDaoTemplate.h"
#import "MessageData.h"

#define MessageEntityName @"Message"

@interface MessageDao : CoreDaoTemplate

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

// Find all messages.
- (NSArray *)findAll;

// Find all normal messages.
- (NSArray *)findNormal;

// Find all control message;
- (NSArray *)findControl;

// Find normal messages sent by a sender(userId).
- (NSArray *)findNormalWithSender:(NSString *)sender;

// Find the normal message with the max sequcne number.
- (Message *)getNormalWithMaxSquenceForSender:(NSString *)sender;

// Find the message in a messageIds array.
- (NSArray *)findInMessageIds:(NSArray *)messageIds;

// Find messages in a sequences array with node identifier of sender.
- (NSArray *)findInSequences:(NSArray *)sequences withSender:(NSString *)sender;

// Find sequences in a sequences array with node identifier of sender.
- (NSArray *)findExistedSequencesIn:(NSArray *)sequences withSender:(NSString *)sender;

// Delete all messages.
- (BOOL)deleteAll;

@end
