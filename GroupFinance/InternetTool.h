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

@interface InternetTool : NSObject

+ (AFHTTPSessionManager *)getSessionManager;

//Get all HTTP session managers from AppDelegate.
+ (NSDictionary *)getSessionManagers;

//Get a HTTP session manager by server address from AppDelegate
+ (AFHTTPSessionManager *)getSessionManagerWithServerAddress:(NSString *)address;

+ (NSString *)createUrl:(NSString *)relativePosition withServerAddress:(NSString *)address;

+ (NSDictionary *)getResponse:(id  _Nullable)responseObject;

@end
