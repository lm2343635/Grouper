//
//  ReceiveTool.h
//  GroupFinance
//
//  Created by lidaye on 30/12/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^Completion)(void);

@interface ReceiveTool : NSObject

@property (nonatomic) NSInteger received;

- (void)receiveWithCompletion:(Completion)completion;

@end
