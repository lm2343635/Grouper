//
//  SendTool.h
//  GroupFinance
//
//  Created by lidaye on 04/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DaoManager.h"

@interface SendTool : NSObject

@property (nonatomic) NSInteger sent;

+ (instancetype)sharedInstance;

// Send update message for a sync entity.
- (void)update:(SyncEntity *)object;

// Send delete message for a sync entity.
- (void)delete:(SyncEntity *)object;

@end
