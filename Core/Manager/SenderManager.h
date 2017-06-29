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

// Send an update message for a sync entity.
- (void)update:(NSManagedObject *)entity;

// Delete a sync entity and send a delete message.
- (void)delete:(NSManagedObject *)entity;

// Send update messages for multiple sync entities.
- (void)updateAll:(NSArray *)entities;

// Delete multiple sync entities and send delete messages.
- (void)deleteAll:(NSArray *)entities;

// Send confirm message;
- (void)confirm;

// Send resend message which contains not existed sequences to receiver.
- (void)resend:(NSArray *)sequences to:(NSString *)receiver;

// ******************* Other *******************

// Send existed messages.
- (void)sendExistedMessages:(NSArray *)messages;

@end
