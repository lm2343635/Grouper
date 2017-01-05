//
//  Sender+CoreDataClass.m
//  GroupFinance
//
//  Created by lidaye on 25/12/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "Sender+CoreDataClass.h"
#import "User+CoreDataClass.h"

@implementation Sender

- (void)awakeFromInsert {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super awakeFromInsert];
    if (!self.messageId) {
        self.messageId = [[NSUUID UUID] UUIDString];
    }
}

@end
