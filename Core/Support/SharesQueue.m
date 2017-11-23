//
//  SharesQueue.m
//  AFNetworking
//
//  Created by lidaye on 23/11/2017.
//

#import "SharesQueue.h"

@implementation SharesQueue

- (instancetype)initWithQueue:(NSArray *)queue {
    self = [super init];
    if (self) {
        _state = SharesStop;
        _queue = [[NSMutableArray alloc] initWithArray:queue];
    }
    return self;
}

- (NSString *)dequeue {
    if (_state == SharesSuccess || _state == SharesFailed) {
        return nil;
    }
    if (_queue.count == 0) {
        _state = SharesSuccess;
        return nil;
    }
    if (_state == SharesStop) {
        _state = SharesSending;
    }
    NSString *shares = [_queue objectAtIndex:0];
    [_queue removeObjectAtIndex:0];
    return shares;
}

@end
