//
//  SyncManager.m
//  Grouper
//
//  Created by lidaye on 19/06/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "SyncManager.h"
#import "ReceiverManager.h"
#import "DEBUG.h"

@implementation SyncManager

- (instancetype)initWithDataStack:(DataStack *)dataStack {
    self = [super init];
    if (self != nil) {
        self.dataStack = dataStack;
    }
    return self;
}

- (BOOL)syncMessage:(MessageData *)message
         completion:(SyncCompletion)completion {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSDictionary *content = [NSJSONSerialization JSONObjectWithData:[message.content dataUsingEncoding:NSUTF8StringEncoding]
                                                            options:NSJSONReadingMutableContainers
                                                              error:nil];
    if (content == nil) {
        return NO;
    }
    if ([message.type isEqualToString:@"update"]) {
        [Sync compatibleChanges:[NSArray arrayWithObject:content]
                  inEntityNamed:message.object
                      dataStack:_dataStack
                     operations:CompatibleOperationOptionsInsertUpdate
                     completion:^(NSError * error) {
                         completion();
                     }];
    } else if ([message.type isEqualToString:@"delete"]) {
        NSString *remoteId = [content valueForKey:@"id"];
        [Sync delete:remoteId
       inEntityNamed:message.object
               using:_dataStack.mainContext
               error:nil];
        completion();
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedNewObject" object:message];
    return YES;
}

@end
