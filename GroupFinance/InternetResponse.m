//
//  InternetResponse.m
//  GroupFinance
//
//  Created by 李大爷的电脑 on 06/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "InternetResponse.h"

@implementation InternetResponse
- (instancetype) initWithResponseObject:(id)responseObject {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self = [super init];
    if(self) {
        _data = [NSJSONSerialization JSONObjectWithData:responseObject
                                                options:NSJSONReadingAllowFragments
                                                  error:nil];
    }
    if(DEBUG) {
        NSLog(@"Get Message from server: %@", self.data);
    }
    return self;
}

- (instancetype)initWithError:(NSError *)error {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
        NSLog(@"InternetResponse init with an error, error.code = %ld", error.code);
    }
    self = [super init];
    
    if (error.code == NSURLErrorNotConnectedToInternet ||
        error.code == NSURLErrorDNSLookupFailed ||
        error.code == NSURLErrorCannotFindHost ||
        error.code == NSURLErrorCannotConnectToHost) {
        _data = @{@"error_code": [NSNumber numberWithInteger:ErrorCodeNotConnectedToInternet]};
        return self;
    }
    if(self) {
        _data = [NSJSONSerialization JSONObjectWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey]
                                                options:NSJSONReadingAllowFragments
                                                  error:nil];
        
    }
    if(DEBUG) {
        NSLog(@"Get Error from server: %@", self.data);
    }
    return self;
}

- (BOOL)statusOK {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [[_data valueForKey:@"status"] intValue] == 200;
}

- (id)getResponseResult {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [_data valueForKey:@"result"];
}

- (int)errorCode {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    int erroCode = [[_data valueForKey:@"error_code"] intValue];
    return erroCode;
}
@end
