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

@interface SyncManager : NSObject

@property (nonatomic, strong) DataStack *dataStack;

- (instancetype)initWithDataStack:(DataStack *)dataStack;

- (BOOL)syncWithMessageData:(MessageData *)message;

@end
