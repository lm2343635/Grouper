//
//  SharesQueue.h
//  AFNetworking
//
//  Created by lidaye on 23/11/2017.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    SharesStop = -1,
    SharesSending = 0,
    SharesSuccess = 1,
    SharesFailed = 2,
} SharesSendingState;

@interface SharesQueue : NSObject

@property (nonatomic) NSInteger state;
@property (nonatomic, strong) NSMutableArray *queue;

- (instancetype)initWithQueue:(NSArray *)queue;

- (NSString *)dequeue;

@end
