//
//  MessageDao.m
//  GroupFinance
//
//  Created by lidaye on 27/03/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "MessageDao.h"

@implementation MessageDao

- (Message *)saveWithMessageData:(MessageData *)messageData {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Message *message = [NSEntityDescription insertNewObjectForEntityForName:MessageEntityName inManagedObjectContext:self.context];
    message.messageId = messageData.messageId;
    message.sendtime = [NSNumber numberWithLongLong:messageData.sendtime];
    [self saveContext];
    return message;
}


@end
