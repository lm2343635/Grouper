//
//  InternetTool.m
//  GroupFinance
//
//  Created by 李大爷的电脑 on 06/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "InternetTool.h"

@implementation InternetTool

+ (AFHTTPSessionManager *)getSessionManager {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate.sessionManager;
}

+ (NSDictionary *)getSessionManagers {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate.sessionManagers;
}

+ (void)refreshSessionManagers {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate refreshSessionManagers];
}

+ (AFHTTPSessionManager *)getSessionManagerWithServerAddress:(NSString *)address {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSDictionary *managers = [self getSessionManagers];
    return [managers objectForKey:address];
}

+ (NSString *)createUrl:(NSString *)relativePosition withServerAddress:(NSString *)address {
    NSString *url=[NSString stringWithFormat:@"http://%@/%@", address, relativePosition];
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
        NSLog(@"Request URL is: %@",url);
    }
    return url;
}

+ (NSDictionary *)getResponse:(id)responseObject {
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:NSJSONReadingAllowFragments
                                                               error:nil];
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
        NSLog(@"Get Message from server: %@", response);
    }
    return response;
}

@end
