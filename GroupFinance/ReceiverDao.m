//
//  ReceiverDao.m
//  GroupFinance
//
//  Created by lidaye on 15/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "ReceiverDao.h"

@implementation ReceiverDao

- (Receiver *)saveWithShareId:(NSString *)shareId {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Receiver *receiver = [NSEntityDescription insertNewObjectForEntityForName:ReceiverEntityName
                                                       inManagedObjectContext:self.context];
    receiver.shareId = shareId;
    receiver.receiveTime = [NSDate date];
    [self saveContext];
    return receiver;
}

- (NSArray *)findInShareIds:(NSArray *)shareIds {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [self findByPredicate:[NSPredicate predicateWithFormat:@"shareId IN %@", shareIds]
                  withEntityName:ReceiverEntityName];
}

- (BOOL)deleteAll {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSFetchRequest *fetchrequest = [[NSFetchRequest alloc] initWithEntityName:ReceiverEntityName];
    NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchrequest];
    NSError *error = nil;
    [self.context.persistentStoreCoordinator executeRequest:deleteRequest
                                                withContext:self.context
                                                      error:&error];
    if (error) {
        NSLog(@"Delete all %@ with error: %@", ReceiverEntityName, error.localizedDescription);
        return NO;
    }
    return YES;
}

@end
