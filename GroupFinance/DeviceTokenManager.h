//
//  DeviceTokenManager.h
//  GroupFinance
//
//  Created by lidaye on 13/02/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceTokenManager : NSObject

@property (nonatomic, strong) NSString *deviceToken;

// Get single instance.
+ (instancetype)sharedInstance;

// Send device token from APNs server to untrusted server.
- (void)sendDeviceToken;

@end
