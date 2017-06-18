//
//  ReceiveTool.h
//  GroupFinance
//
//  Created by lidaye on 30/12/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ReceivedTag @"received"

typedef void (^Completion)(void);

@interface ReceiveManager: NSObject

// Get single instance.
+ (instancetype)sharedInstance;

// Receive message and do something in completion block.
- (void)receiveWithCompletion:(Completion)completion;

@end
