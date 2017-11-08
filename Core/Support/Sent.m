//
//  Sent.m
//  AFNetworking
//
//  Created by lidaye on 08/11/2017.
//

#import "Sent.h"

@implementation Sent

- (instancetype)initWithTarget:(NSInteger)target {
    self = [super init];
    if (self) {
        _success = 0;
        _fail = 0;
        _target = target;
    }
    return self;
}

- (BOOL)isFinished {
    // If all HTTP request has been sent successfully and there is no failed HTTP request,
    // we regard this Sent success.
    return _success == _target && _fail == 0;
}

@end
