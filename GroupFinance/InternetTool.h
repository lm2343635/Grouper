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

+ (AFHTTPSessionManager * _Nonnull)getSessionManager;

//Get all HTTP session managers from AppDelegate.
+ (NSDictionary * _Nullable)getSessionManagers;

//Refresh session managers.
+ (void)refreshSessionManagers;

//Get a HTTP session manager by server address from AppDelegate
+ (AFHTTPSessionManager * _Nullable)getSessionManagerWithServerAddress:(NSString *)address;

+ (NSString * _Nonnull)createUrl:(NSString *)relativePosition withServerAddress:(NSString *)address;

+ (NSDictionary * _Nullable)getResponse:(id  _Nullable)responseObject;

@end
