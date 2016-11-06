//
//  InternetTool.h
//  GroupFinance
//
//  Created by 李大爷的电脑 on 06/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "InternetResponse.h"

#define DoaminName @"127.0.0.1:8080"

@interface InternetTool : NSObject

//Get AFHTTPSessionManager with token if signed in
+ (AFHTTPSessionManager *)getSessionManager;

+ (NSString *)createUrl:(NSString *)relativePosition;

+ (NSDictionary *)getResponse:(id  _Nullable)responseObject;

@end
