//
//  InternetResponse.m
//  GroupFinance
//
//  Created by 李大爷的电脑 on 06/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "InternetResponse.h"
#import "DEBUG.h"

@implementation InternetResponse
- (instancetype) initWithResponseObject:(id)responseObject {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self = [super init];
    if (self) {
        _data = [NSJSONSerialization JSONObjectWithData:responseObject
                                                options:NSJSONReadingAllowFragments
                                                  error:nil];
    }
    if (DEBUG) {
        NSLog(@"Get Message from server: %@", self.data);
    }
    return self;
}

- (instancetype)initWithError:(NSError *)error {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
        NSLog(@"InternetResponse init with an error, error.code = %ld", (long)error.code);
    }
    self = [super init];
    
    if (error.code == NSURLErrorNotConnectedToInternet ||
        error.code == NSURLErrorDNSLookupFailed ||
        error.code == NSURLErrorCannotFindHost ||
        error.code == NSURLErrorCannotConnectToHost) {
        _data = @{@"errorCode": [NSNumber numberWithInteger:ErrorNotConnectedToInternet]};
        return self;
    }

    if (DEBUG) {
        NSLog(@"AFNetworkingOperationFailingURLResponseErrorKey:\n%@", error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey]);
    }
    
    if (self) {
        NSObject *dataErrorKey = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if (dataErrorKey != nil) {
            if (DEBUG) {
                NSLog(@"AFNetworkingOperationFailingURLResponseDataErrorKey:\n%@", [[NSString alloc] initWithData:(NSData *)dataErrorKey encoding:NSUTF8StringEncoding]);
            }
            _data = [NSJSONSerialization JSONObjectWithData:(NSData *)dataErrorKey
                                                    options:NSJSONReadingAllowFragments
                                                      error:nil];
        }
    }
    return self;
}

- (BOOL)statusOK {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (_data == nil) {
        return false;
    }
    return [[_data valueForKey:@"status"] intValue] == 200;
}

- (id)getResponseResult {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (_data == nil) {
        return nil;
    }
    return [_data valueForKey:@"result"];
}

- (int)errorCode {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (_data == nil) {
        return 0;
    }
    int erroCode = [[_data valueForKey:@"errorCode"] intValue];
    return erroCode;
}
@end
