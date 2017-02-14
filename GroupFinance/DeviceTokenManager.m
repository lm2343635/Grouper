//
//  DeviceTokenManager.m
//  GroupFinance
//
//  Created by lidaye on 13/02/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "DeviceTokenManager.h"
#import "InternetTool.h"
#import "GroupTool.h"

@implementation DeviceTokenManager {
    NSDictionary *managers;
    GroupTool *group;
    NSUserDefaults *defaults;
}

+ (instancetype)sharedInstance {
    static DeviceTokenManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DeviceTokenManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        managers = [InternetTool getSessionManagers];
        group = [GroupTool sharedInstance];
        defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (void)sendDeviceToken {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (_deviceToken == nil) {
        return;
    }
    for (NSString *address in group.servers.allKeys) {
        [managers[address] POST:[InternetTool createUrl:@"user/deviceToken" withServerAddress:address]
                     parameters:@{@"deviceToken": _deviceToken}
                       progress:nil
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                            if ([response statusOK]) {
                                NSObject *result = [response getResponseResult];
                                if ([[result valueForKey:@"success"] intValue] == 1) {
                                    if (DEBUG) {
                                        NSLog(@"Send device token to untrusted server %@", address);
                                    }
                                }
                            }
                        }
                        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                            InternetResponse *response = [[InternetResponse alloc] initWithError:error];
                            switch ([response errorCode]) {
                                case ErrorAccessKey:
                                    
                                    break;
                                default:
                                    break;
                            }
                        }];
    }
    
}

@synthesize deviceToken = _deviceToken;

- (void)setDeviceToken:(NSString *)deviceToken {
    _deviceToken = deviceToken;
    [defaults setObject:deviceToken forKey:NSStringFromSelector(@selector(deviceToken))];
}

- (NSString *)deviceToken {
    if (_deviceToken == nil) {
        _deviceToken = [defaults objectForKey:NSStringFromSelector(_cmd)];
    }
    return _deviceToken;
}

@end
