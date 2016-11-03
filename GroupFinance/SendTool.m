//
//  SendTool.m
//  GroupFinance
//
//  Created by lidaye on 04/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "SendTool.h"
#import "SecretSharing.h"

#define PARTS 3
#define RECOVER 2

@implementation SendTool

+ (void)sendWithSender:(Sender *)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSArray *shares = [SecretSharing generateSharesWith:sender.content parts:PARTS recover:RECOVER];
    NSLog(@"%@", shares);
    sender.sendtime = [NSDate date];
}

@end
