//
//  Grouper.h
//  Grouper
//
//  Created by lidaye on 19/06/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SenderManager.h"
#import "ReceiverManager.h"
#import "GroupManager.h"
#import "UIManager.h"
#import "DEBUG.h"

@interface Grouper : NSObject

@property (nonatomic, strong) GroupManager *group;
@property (nonatomic, strong) SenderManager *sender;
@property (nonatomic, strong) ReceiverManager *receiver;
@property (nonatomic, strong) UIManager *ui;

+ (instancetype)sharedInstance;

// Core layer grouper set up method for general device(all platform).
- (void)setupWithAppId:(NSString *)appId
              entities:(NSArray *)entities
             dataStack:(DataStack *)stack;

// Grouper set up method for iOS device.
- (void)setupWithAppId:(NSString *)appId
              entities:(NSArray *)entities
             dataStack:(DataStack *)stack
        mainStoryboard:(UIStoryboard *)storyboard;

@end
