//
//  Processing.h
//  Pods
//
//  Created by lidaye on 04/08/2017.
//
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    SendingStart = 0,
    DataSync = 1,
    SecretSharing = 2,
    Network = 3,
    ReceivingStart = 4
} ProcessingState;

typedef enum : NSUInteger {
    Sending = 0,
    Receiving = 1,
} ProcessingType;

@interface Processing : NSObject

@property (nonatomic) double sync;
@property (nonatomic) double secret;
@property (nonatomic) double network;
@property (nonatomic) double total;

- (instancetype)initWithType:(ProcessingType)type;

- (BOOL)dataSynchronized;
- (BOOL)secretSharing;
- (BOOL)networkFinished;

- (void)directFinish;

@end
