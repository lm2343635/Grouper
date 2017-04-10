//
//  MessageDao.m
//  GroupFinance
//
//  Created by lidaye on 27/03/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "MessageDao.h"
#import "Defaults.h"

@implementation MessageDao

- (Message *)saveWithMessageData:(MessageData *)messageData {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Message *message = [NSEntityDescription insertNewObjectForEntityForName:MessageEntityName inManagedObjectContext:self.context];
    message.messageId = messageData.messageId;
    message.sendtime = [NSNumber numberWithLong:messageData.sendtime];
    message.sender = messageData.sender;
    message.receiver = messageData.receiver;
    message.content = messageData.content;
    message.object = messageData.object;
    message.objectId = messageData.objectId;
    message.type = messageData.type;
    message.sequence = [NSNumber numberWithLong:messageData.sequence];
    message.node = messageData.node;
    [self saveContext];
    return message;
}

- (Message *)saveWithContent:(NSString *)content
                  objectName:(NSString *)objectName
                    objectId:(NSString *)objectId
                        type:(NSString *)type
                        from:(NSString *)sender
                          to:(NSString *)receiver
                    sequence:(long)sequence
                        node:(NSString *)node {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Message *message = [NSEntityDescription insertNewObjectForEntityForName:MessageEntityName
                                                     inManagedObjectContext:self.context];
    // Generate a messageId by UUID if Grouper create a new message in a device.
    message.messageId = [[NSUUID UUID] UUIDString];
    // Fill other attributes
    message.object = objectName;
    message.objectId = objectId;
    message.content = content;
    message.sendtime = [NSNumber numberWithLong:(long)[[NSDate date] timeIntervalSince1970]];
    message.type = type;
    message.sender = sender;
    message.receiver = receiver;
    message.sequence = [NSNumber numberWithLong:sequence];
    message.node = node;
    [self saveContext];
    return message;
}

- (NSArray *)findNormal {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [self findByPredicate:[NSPredicate predicateWithFormat:@"object!=nil"]
                  withEntityName:MessageEntityName];
}

- (NSArray *)findControl {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [self findByPredicate:[NSPredicate predicateWithFormat:@"object=nil"]
                  withEntityName:MessageEntityName];
}

- (NSArray *)findNormalWithSender:(NSString *)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [self findByPredicate:[NSPredicate predicateWithFormat:@"object!=nil and sender=%@", sender]
                  withEntityName:MessageEntityName];
}

- (NSArray *)findAll {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [self findAllWithEntityName:MessageEntityName];
}

- (NSArray *)findInSequences:(NSArray *)sequences withNode:(NSString *)node {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [self findByPredicate:[NSPredicate predicateWithFormat:@"sequence IN %@ and node = %@", sequences, node]
                  withEntityName:MessageEntityName];
}

- (NSArray *)findExistedSequencesIn:(NSArray *)sequences withNode:(NSString *)node {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:MessageEntityName];
    [request setResultType:NSDictionaryResultType];
    [request setPropertiesToFetch:[NSArray arrayWithObjects:@"sequence", nil]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"sequence IN %@ and node = %@", sequences, node]];
    NSError *error = nil;
    NSArray *objects = [self.context executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Error: %@",error);
        return nil;
    }
    NSMutableArray *existedSequences = [[NSMutableArray alloc] init];
    for (NSObject *object in objects) {
        [existedSequences addObject:[object valueForKey:@"sequence"]];
    }
    return existedSequences;
}

@end
