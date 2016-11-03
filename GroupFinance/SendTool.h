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

+ (void)sendWithSender:(Sender *)sender;

@end
