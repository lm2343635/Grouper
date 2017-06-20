//
//  InternetTool.h
//  GroupFinance
//
//  Created by 李大爷的电脑 on 06/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InternetResponse.h"

@interface NetManager : NSObject

@property (strong, nonatomic) NSDictionary * _Nonnull managers;
@property (strong, nonatomic) AFHTTPSessionManager * _Nonnull manager;

// Get single instance.
+ (instancetype _Nonnull )sharedInstance;

// Get a HTTP session manager by server address from AppDelegate
- (AFHTTPSessionManager * _Nullable)getSessionManagerWithServerAddress:(NSString *_Nonnull)address;

// Refresh session managers.
- (void)refreshSessionManagers;

//**************** Static methods ******************

// Create request URL
+ (NSString * _Nonnull)createUrl:(NSString *_Nonnull)relativePosition withServerAddress:(NSString *_Nonnull)address;

// Get response dictionary from a response object
+ (NSDictionary * _Nullable)getResponse:(id  _Nullable)responseObject;

@end
