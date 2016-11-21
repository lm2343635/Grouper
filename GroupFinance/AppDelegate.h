//
//  AppDelegate.h
//  GroupFinance
//
//  Created by lidaye on 4/23/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <AFNetworking/AFNetworking.h>
#import "MCManager.h"
@import DATAStack;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSDictionary *sessionManagers;
@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;
@property (strong, nonatomic) DATAStack *dataStack;
@property (strong, nonatomic) MCManager *mcManager;

@end

