//
//  DeviceTokenManager.m
//  GroupFinance
//
//  Created by lidaye on 13/02/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "DeviceTokenManager.h"

@implementation DeviceTokenManager

+ (instancetype)sharedInstance {
    static DeviceTokenManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DeviceTokenManager alloc] init];
    });
    return instance;
}

@end
