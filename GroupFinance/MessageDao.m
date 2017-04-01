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

- (Message *)saveWithContent:(NSString *)content
                  objectName:(NSString *)objectName
                    objectId:(NSString *)objectId
                        type:(NSString *)type
                        from:(NSString *)sender
                          to:(NSString *)receiver {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Message *message = [NSEntityDescription insertNewObjectForEntityForName:MessageEntityName
                                                     inManagedObjectContext:self.context];
    message.object = objectName;
    message.objectId = objectId;
    message.content = content;
    message.sendtime = [NSNumber numberWithLongLong:(long long)([[NSDate date] timeIntervalSince1970] * 1000)];
    message.type = type;
    message.sender = sender;
    message.receiver = receiver;
    [self saveContext];
    return message;
}

- (NSArray *)findNormal {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"object!=nil"];
    return [self findByPredicate:predicate withEntityName:MessageEntityName];
}

- (NSArray *)findAll {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [self findAllWithEntityName:MessageEntityName];
}

@end
