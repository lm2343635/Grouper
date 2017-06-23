//
//  SendTool.h
//  GroupFinance
//
//  Created by lidaye on 04/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDaoManager.h"

#define MessageTypeUpdate @"update"
#define MessageTypeDelete @"delete"
#define MessageTypeConfirm @"confirm"
#define MessageTypeResend @"resend"

@interface SenderManager : NSObject

// Get single instance.
+ (instancetype)sharedInstance;

// ******************* Create message and send shares to untrusted servers. *******************

// Send update message for a sync entity.
- (BOOL)update:(NSManagedObject *)object;

// Send delete message for a sync entity.
- (BOOL)delete:(NSManagedObject *)object;

// Send confirm message;
- (void)confirm;

// Send resend message which contains not existed sequences to receiver.
- (void)resend:(NSArray *)sequences to:(NSString *)receiver;

// ******************* Other *******************

// Send existed messages.
- (void)sendExistedMessages:(NSArray *)messages;

@end
