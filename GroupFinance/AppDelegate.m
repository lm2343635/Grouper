//
//  AppDelegate.m
//  GroupFinance
//
//  Created by lidaye on 4/23/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AppDelegate.h"
#import "GroupManager.h"
#import "DeviceTokenManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate {
    GroupManager *group;
    DeviceTokenManager *deviceTokenManager;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    //Register Remote Notification, support iOS version after 8.0
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    group = [GroupManager sharedInstance];
    deviceTokenManager = [DeviceTokenManager sharedInstance];
    
    if (DEBUG) {
        NSLog(@"Number of group menbers is %ld", (long)group.members);
        NSLog(@"Group id is %@, group name is %@, group owner is %@", group.defaults.groupId, group.defaults.groupName, group.defaults.owner);
        for (NSString *address in group.defaults.servers.allKeys) {
            NSLog(@"Untrusted server %@, access key is %@", address, group.defaults.servers[address]);
        }
    }
    
    _mcManager = [[MCManager alloc] init];
    
    // Indicate to the system that your app wishes to perform background fetch
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    //Init facebook OAuth.
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];

    
    //Set root view controller.
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] == nil) {
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

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSString *token = [[[[deviceToken description]
                          stringByReplacingOccurrencesOfString: @"<" withString: @""]
                         stringByReplacingOccurrencesOfString: @">" withString: @""]
                        stringByReplacingOccurrencesOfString: @" " withString: @""];
    if (DEBUG) {
        NSLog(@"Device token from APNs server is %@", token);
    }
    deviceTokenManager.deviceToken = token;
    [deviceTokenManager sendDeviceToken];
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
    // Add user logic here.
    return handled;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSLog(@"Background fetch started...");
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
