//
//  Grouper.m
//  Grouper
//
//  Created by lidaye on 19/06/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "Grouper.h"

@implementation Grouper

+ (instancetype)sharedInstance {
    static Grouper *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[Grouper alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self = [super init];
    if (self) {
        _group = [GroupManager sharedInstance];
        _sender = [SenderManager sharedInstance];
        _receiver = [ReceiverManager sharedInstance];
        _ui = [UIManager sharedInstance];
    }
    return self;
}

- (void)setupWithAppId:(NSString *)appId dataStack:(DataStack *)stack {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // Setup appId and MC manager.
    _group.appId = appId;
    [_group setupMutipeerConnectivity];
    
    // Set up data stack and init sync manager.
    _group.appDataStack = stack;
    [_receiver initSyncManager:_group.appDataStack];
    
    // Sent unsent messages.
    [_sender unsent];

}

- (void)setupWithAppId:(NSString *)appId
             dataStack:(DataStack *)stack
        mainStoryboard:(UIStoryboard *)storyboard {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self setupWithAppId:appId dataStack:stack];
    // Set up main storyboard.
    _ui.main = storyboard;
}

@end
