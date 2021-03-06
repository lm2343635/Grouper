//
//  GroupTool.m
//  GroupFinance
//
//  Created by lidaye on 19/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "Defaults.h"

@implementation Defaults {
    NSUserDefaults *defaults;
}

+ (instancetype)sharedInstance {
    static Defaults *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[Defaults alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

@synthesize me = _me;

- (void)setMe:(NSString *)me {
    _me = me;
    [defaults setObject:me forKey:NSStringFromSelector(@selector(me))];
}

- (NSString *)me {
    if (_me == nil) {
        _me = [defaults objectForKey:NSStringFromSelector(@selector(me))];
    }
    return _me;
}

@synthesize owner = _owner;

- (void)setOwner:(NSString *)owner {
    _owner = owner;
    [defaults setObject:owner forKey:NSStringFromSelector(@selector(owner))];
}

- (NSString *)owner {
    if (_owner == nil) {
        _owner = [defaults objectForKey:NSStringFromSelector(@selector(owner))];
    }
    return _owner;
}

@synthesize members = _members;

- (void)setMembers:(NSInteger)members {
    _members = members;
    [defaults setInteger:members forKey:NSStringFromSelector(@selector(members))];
}

- (NSInteger)members {
    if (_members == 0) {
        _members = [defaults integerForKey:NSStringFromSelector(@selector(members))];
    }
    return _members;
}

@synthesize groupId = _groupId;

- (void)setGroupId:(NSString *)groupId {
    _groupId = groupId;
    [defaults setObject:groupId forKey:NSStringFromSelector(@selector(groupId))];
}

- (NSString *)groupId {
    if (_groupId == nil) {
        _groupId = [defaults stringForKey:NSStringFromSelector(@selector(groupId))];
    }
    return _groupId;
}

@synthesize groupName = _groupName;

- (void)setGroupName:(NSString *)groupName {
    _groupName = groupName;
    [defaults setObject:groupName forKey:NSStringFromSelector(@selector(groupName))];
}

- (NSString *)groupName {
    if (_groupName == nil) {
        _groupName = [defaults stringForKey:NSStringFromSelector(@selector(groupName))];
    }
    return _groupName;
}

@synthesize servers = _servers;

- (void)setServers:(NSArray *)servers {
    _servers = servers;
    [defaults setObject:servers forKey:NSStringFromSelector(@selector(servers))];
}

- (NSArray *)servers {
    if (_servers == nil) {
        _servers = [defaults objectForKey:NSStringFromSelector(@selector(servers))];
    }
    return _servers;
}

@synthesize keys = _keys;

- (void)setKeys:(NSArray *)keys {
    _keys = keys;
    [defaults setObject:keys forKey:NSStringFromSelector(@selector(keys))];
}

- (NSArray *)keys {
    if (_keys == nil) {
        _keys = [defaults objectForKey:NSStringFromSelector(@selector(keys))];
    }
    return _keys;
}

- (NSUInteger)addServerAddress:(NSString *)address withAccessKey:(NSString *)accessKey {
    NSMutableArray *servers = [[NSMutableArray alloc] initWithArray:[self servers]];
    NSMutableArray *keys = [[NSMutableArray alloc] initWithArray:[self keys]];
    [servers addObject:address];
    [keys addObject:accessKey];
    [self setServers:servers];
    [self setKeys:keys];
    return servers.count;
}

@synthesize serverCount = _serverCount;

- (void)setServerCount:(NSInteger)serverCount {
    _serverCount = serverCount;
    [defaults setInteger:serverCount forKey:NSStringFromSelector(@selector(serverCount))];
}

- (NSInteger)serverCount {
    if (_serverCount == 0) {
        _serverCount = [defaults integerForKey:NSStringFromSelector(@selector(serverCount))];
    }
    return _serverCount;
}

@synthesize threshold = _threshold;

- (void)setThreshold:(NSInteger)threshold {
    _threshold = threshold;
    [defaults setInteger:threshold forKey:NSStringFromSelector(@selector(threshold))];
}

- (NSInteger)threshold {
    if (_threshold == 0) {
        _threshold = [defaults integerForKey:NSStringFromSelector(@selector(threshold))];
    }
    return _threshold;
}

@synthesize safeServerCount = _safeServerCount;

- (void)setSafeServerCount:(NSInteger)safeServerCount {
    _safeServerCount = safeServerCount;
    [defaults setInteger:safeServerCount forKey:NSStringFromSelector(@selector(safeServerCount))];
}

- (NSInteger)safeServerCount {
    if (_safeServerCount == 0) {
        _safeServerCount = [defaults integerForKey:NSStringFromSelector(@selector(safeServerCount))];
    }
    return _safeServerCount;
}

@synthesize interval = _interval;

- (void)setInterval:(NSInteger)interval {
    _interval = interval;
    [defaults setInteger:interval forKey:NSStringFromSelector(@selector(interval))];
}

- (NSInteger)interval {
    if (_interval == 0) {
        _interval = [defaults integerForKey:NSStringFromSelector(@selector(interval))];
    }
    return _interval;
}

@synthesize node = _node;
- (NSString *)node {
    if (_node == nil) {
        _node = [defaults stringForKey:NSStringFromSelector(@selector(node))];
        if (_node == nil) {
            NSString *uuid = [[NSUUID UUID] UUIDString];
            [defaults setObject:uuid forKey:NSStringFromSelector(@selector(node))];
            _node = uuid;
        }
    }
    return _node;
}

@synthesize sequence = _sequence;

- (void)setSequence:(NSInteger)sequence {
    _sequence = sequence;
    [defaults setInteger:sequence forKey:NSStringFromSelector(@selector(sequence))];
}

- (NSInteger)sequence {
    if (_sequence == 0) {
        _sequence = [defaults integerForKey:NSStringFromSelector(@selector(sequence))];
    }
    return _sequence;
}

@synthesize initial = _initial;

- (void)setInitial:(NSInteger)initial {
    _initial = initial;
    [defaults setInteger:initial forKey:NSStringFromSelector(@selector(initial))];
}

- (NSInteger)initial {
    if (_initial == 0) {
        _initial = [defaults integerForKey:NSStringFromSelector(@selector(initial))];
    }
    return _initial;
}

@synthesize controlMessageSendTime = _controlMessageSendTime;

- (void)setControlMessageSendTime:(NSInteger)controlMessageSendTime {
    _controlMessageSendTime = controlMessageSendTime;
    [defaults setInteger:controlMessageSendTime forKey:NSStringFromSelector(@selector(controlMessageSendTime))];
}

- (NSInteger)controlMessageSendTime {
    if (_controlMessageSendTime == 0) {
        _controlMessageSendTime = [defaults integerForKey:NSStringFromSelector(@selector(controlMessageSendTime))];
    }
    return _controlMessageSendTime;
}

@synthesize unsentMessageIds = _unsentMessageIds;

- (void)setUnsentMessageIds:(NSArray *)unsentMessageIds {
    _unsentMessageIds = unsentMessageIds;
    [defaults setObject:unsentMessageIds forKey:NSStringFromSelector(@selector(unsentMessageIds))];
}

- (NSArray *)unsentMessageIds {
    if (_unsentMessageIds == nil) {
        _unsentMessageIds = [defaults objectForKey:NSStringFromSelector(@selector(unsentMessageIds))];
    }
    return _unsentMessageIds;
}

@end
