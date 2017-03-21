//
//  ReceiveTool.h
//  GroupFinance
//
//  Created by lidaye on 30/12/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^Completion)(void);

@interface ReceiveManager: NSObject

@property (nonatomic) NSInteger received;

// Get single instance.
+ (instancetype)sharedInstance;

// Receive message and do something in completion block.
- (void)receiveWithCompletion:(Completion)completion;

@end
