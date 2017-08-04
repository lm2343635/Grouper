//
//  Processing.m
//  Pods
//
//  Created by lidaye on 04/08/2017.
//
//

#import "Processing.h"

@implementation Processing {
    double time;
    ProcessingState state;
    ProcessingType type;
}

- (instancetype)init {
    return [self initWithType:Sending];
}

- (instancetype)initWithType:(ProcessingType)processingType {
    self = [super init];
    if (self) {
        type = processingType;
        time = [[NSDate date] timeIntervalSince1970];
        if (type == Sending) {
            state = SendingStart;
        } else if (type == Receiving) {
            state = ReceivingStart;
        }
    }
    return self;
}

- (BOOL)dataSynchronized {
    if ((type == Sending && state != SendingStart) || (type == Receiving && state != SecretSharing)) {
        return NO;
    }
    
    double now = [[NSDate date] timeIntervalSince1970];
    _sync = now - time;
    time = now;
    state = DataSync;
    if (type == Receiving) {
        _total = _sync + _secret + _network;
    }
    return YES;
}

- (BOOL)secretSharing {
    if ((type == Sending && state != DataSync) || (type == Receiving && state != Network)) {
        return NO;
    }
    double now = [[NSDate date] timeIntervalSince1970];
    _secret = now - time;
    time = now;
    state = SecretSharing;
    return YES;
}

- (BOOL)networkFinished {
    if ((type == Sending && state != SecretSharing) || (type == Receiving && state != ReceivingStart)) {
        return NO;
    }
    double now = [[NSDate date] timeIntervalSince1970];
    _network = now - time;
    time = now;
    state = Network;
    if (type == Sending) {
        _total = _sync + _secret + _network;
    }
    return YES;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"total %fs, data sync: %fs, secret sharing: %fs, network: %fs.", _total, _sync, _secret, _network];
}

@end
