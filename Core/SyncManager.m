//
//  SyncManager.m
//  Grouper
//
//  Created by lidaye on 19/06/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "SyncManager.h"

@implementation SyncManager

- (instancetype)initWithDataStack:(DataStack *)dataStack {
    self = [super init];
    if (self != nil) {
        self.dataStack = dataStack;
    }
    return self;
}

- (BOOL)syncWithMessageData:(MessageData *)message {
    NSDictionary *content = [NSJSONSerialization JSONObjectWithData:[message.content dataUsingEncoding:NSUTF8StringEncoding]
                                                            options:NSJSONReadingMutableContainers
                                                              error:nil];
    if (content == nil) {
        return NO;
    }
    if ([message.type isEqualToString:@"update"]) {
        [Sync changes:[NSArray arrayWithObject:content]
        inEntityNamed:message.object
            dataStack:_dataStack
           completion:nil];
    } else if ([message.type isEqualToString:@"delete"]) {
        NSString *remoteId = [content valueForKey:@"id"];
        [Sync delete:remoteId
       inEntityNamed:message.object
               using:_dataStack.mainContext
               error:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedNewObject" object:message];
    return YES;
}

@end
