//
//  AppDelegate.m
//  GroupFinance
//
//  Created by lidaye on 4/23/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AppDelegate.h"
#import "DaoManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }

    //Init facebook OAuth.
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    //Init AFHTTPSessionManager.
    [self httpSessionManager];
    
    //Set root view controller.
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"uid"] == nil) {
        [self setRootViewControllerWithIdentifer:@"loginViewController"];
    } else {
        [self setRootViewControllerWithIdentifer:@"mainTabBarController"];
    }
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
        NSLog(@"Register remote notification success, token = %@", deviceToken);
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
        NSLog(@"Register remote notification failed with error: %@", error.localizedDescription);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
        
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                               annotation:options[UIApplicationOpenURLOptionsAnnotationKey]
                    ];
    // 在此添加任意自定义逻辑。
    return handled;
}

#pragma mark - DataStack
@synthesize dataStack = _dataStack;

- (DATAStack *)dataStack {
    if (_dataStack) {
        return _dataStack;
    }
    _dataStack = [[DATAStack alloc] initWithModelName:@"Model"];
    return _dataStack;
}

#pragma mark - AFNetworking
@synthesize httpSessionManager = _httpSessionManager;

- (AFHTTPSessionManager *)httpSessionManager {
    if(_httpSessionManager != nil) {
        return _httpSessionManager;
    }
    _httpSessionManager = [AFHTTPSessionManager manager];
    _httpSessionManager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    return _httpSessionManager;
}

#pragma mark - Service
- (void)setRootViewControllerWithIdentifer:(NSString *)identifer {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:identifer];
    [self.window makeKeyAndVisible];
}

@end
