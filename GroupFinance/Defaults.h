//
//  GroupTool.h
//  GroupFinance
//
//  Created by lidaye on 19/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Defaults : NSObject

typedef NS_OPTIONS(NSUInteger, InitialState) {
    NotInitial = 0,
    RestoringServer = 2,
    AddingNewServer = 3,
    InitialFinished = 4
};

// User id of owner
@property (nonatomic) NSString *owner;
// Number of menbers
@property (nonatomic) NSInteger members;

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSDictionary *servers;
@property (nonatomic) NSInteger serverCount;
@property (nonatomic) NSInteger threshold;

// Node identifier of this device, it will be generated when the user sign in in this device.
// Node identifier will not be change after Grouper generated it. When user uninstall Group and reinstall again, a new node identifier will be generated.
@property (nonatomic, strong) NSString *node;

// Init state
@property (nonatomic) NSInteger initial;

// Last control message send time.
@property (nonatomic) NSInteger controlMessageSendTime;

- (NSUInteger)addServerAddress:(NSString *)address withAccessKey:(NSString *)accessKey;

+ (instancetype)sharedInstance;

@end
