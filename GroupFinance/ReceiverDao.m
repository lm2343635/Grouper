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

@end
