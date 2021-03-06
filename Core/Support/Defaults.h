//
//  GroupTool.h
//  GroupFinance
//
//  Created by lidaye on 19/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Defaults : NSObject

// Group state in this device
typedef NS_OPTIONS(NSUInteger, InitialState) {
    // Group has not be initialized, user cannot do anything except add a new server or restore an existed server.
    NotInitial = 0,
    // User is storing existed servers. User cannot add new servers in this state because user has joined a group before.
    RestoringServer = 2,
    // User is adding new servers. User cannot store existed server in this state.
    AddingNewServer = 3,
    // User has initialized Grouper app successfully, user can add sync entitiy from now!
    InitialFinished = 4
};

// ************************* Attributes **************************

// Email address of current user
@property (nonatomic, strong) NSString *me;

// Email address of owner
@property (nonatomic, strong) NSString *owner;

// Number of menbers
@property (nonatomic) NSInteger members;

// GroupId should be unique in an untrusted server.
@property (nonatomic, strong) NSString *groupId;

// Group name can be same in an untrusted server.
@property (nonatomic, strong) NSString *groupName;

// Server addresses
@property (nonatomic, strong) NSArray *servers;

// Access keys for servers
@property (nonatomic, strong) NSArray *keys;

// Number of untrusted servers.
@property (nonatomic) NSInteger serverCount;

// Threshold to recover shares from untrusted servers.
@property (nonatomic) NSInteger threshold;

// The min number of untrusted servers when a sender upload shares, k ≤ s ≤ n.
@property (nonatomic) NSInteger safeServerCount;

// Deletion interval time in untrusted servers.
@property (nonatomic) NSInteger interval;

// Node identifier of this device, it will be generated when the user sign in in this device.
// Node identifier will not be change after Grouper generated it. When user uninstall Group and reinstall again, a new node identifier will be generated.
@property (nonatomic, strong) NSString *node;

// Message sequence.
@property (nonatomic) NSInteger sequence;

// Init state
@property (nonatomic) NSInteger initial;

// Last control message send time.
@property (nonatomic) NSInteger controlMessageSendTime;

@property (nonatomic) NSArray *unsentMessageIds;


// ************************* Methods **************************

// Add an untrusted server with access key for this server.
- (NSUInteger)addServerAddress:(NSString *)address withAccessKey:(NSString *)accessKey;

// Get signle instance of Defaults.
+ (instancetype)sharedInstance;

@end
