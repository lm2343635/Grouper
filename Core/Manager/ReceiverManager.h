//
//  ReceiveTool.h
//  GroupFinance
//
//  Created by lidaye on 30/12/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupManager.h"

#define ReceivedTag @"received"

typedef void (^Completion)(void);

@interface ReceiverManager: NSObject

// Get single instance.
+ (instancetype)sharedInstance;

// Init sync manager in Grouper
- (void)initSyncManager:(DataStack *)stack;

// Receive message and do something in completion block.
- (void)receiveWithCompletion:(Completion)completion;

@end
