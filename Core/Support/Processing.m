//
//  Processing.m
//  Pods
//
//  Created by lidaye on 04/08/2017.
//
//

#import "Processing.h"

#define ProcessingStateStart 0
#define ProcessingStateDataSync 1
#define ProcessingStateSecretSharing 2
#define ProcessingStateNetwork 3

@implementation Processing {
    double time;
    int state;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        time = [[NSDate date] timeIntervalSince1970];
        state = ProcessingStateStart;
    }
    return self;
}

- (BOOL)dataSynchronized {
    if (state >= ProcessingStateDataSync) {
        return NO;
    }
    double now = [[NSDate date] timeIntervalSince1970];
    _sync = now - time;
    time = now;
    state = ProcessingStateDataSync;
    return YES;
}

- (BOOL)secretSharing {
    if (state >= ProcessingStateSecretSharing) {
        return NO;
    }
    double now = [[NSDate date] timeIntervalSince1970];
    _secret = now - time;
    time = now;
    state = ProcessingStateSecretSharing;
    return YES;
}

- (BOOL)networkFinished {
    if (state >= ProcessingStateNetwork) {
        return NO;
    }
    double now = [[NSDate date] timeIntervalSince1970];
    _network = now - time;
    time = now;
    state = ProcessingStateNetwork;
    _total = _sync + _secret + _network;
    return YES;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"total %fs, data sync: %fs, secret sharing: %fs, network: %fs.", _total, _sync, _secret, _network];
}

@end
