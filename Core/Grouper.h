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

- (void)setupWithAppId:(NSString *)appId
             dataStack:(DataStack *)stack
        mainStoryboard:(UIStoryboard *)storyboard;

@end
