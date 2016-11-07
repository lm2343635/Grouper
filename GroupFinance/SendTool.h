//
//  SendTool.h
//  GroupFinance
//
//  Created by lidaye on 04/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sender+CoreDataClass.h"

@interface SendTool : NSObject

@property (nonatomic) NSInteger sent;
@property (strong, nonatomic) Sender *sender;

- (instancetype)initWithSender:(Sender *)sender;
- (void)sendShares;

@end
