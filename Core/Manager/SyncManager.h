//
//  SyncManager.h
//  Grouper
//
//  Created by lidaye on 19/06/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageData.h"
#import "Core-Bridging-Header.h"

typedef void (^SyncCompletion)(BOOL);

@interface SyncManager : NSObject

@property (nonatomic, strong) DataStack *dataStack;

- (instancetype)initWithDataStack:(DataStack *)dataStack;

- (void)syncMessage:(MessageData *)message
         completion:(SyncCompletion)completion;

@end
