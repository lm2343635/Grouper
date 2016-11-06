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
    return delegate.httpSessionManager;
}

+ (NSString *)createUrl:(NSString *)relativePosition {
    NSString *url=[NSString stringWithFormat:@"http://%@/%@", DoaminName, relativePosition];
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
