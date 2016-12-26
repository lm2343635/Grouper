//
//  GroupTool.m
//  GroupFinance
//
//  Created by lidaye on 19/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "GroupTool.h"

@implementation GroupTool {
    NSUserDefaults *defaults;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
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
        _groupId = [defaults objectForKey:NSStringFromSelector(@selector(groupId))];
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
        _groupName = [defaults objectForKey:NSStringFromSelector(@selector(groupName))];
    }
    return _groupName;
}

@synthesize servers = _servers;

- (void)setServers:(NSDictionary *)servers {
    _servers = servers;
    [defaults setObject:servers forKey:NSStringFromSelector(@selector(servers))];
}

- (NSDictionary *)servers {
    if (_servers == nil) {
        _servers = [defaults objectForKey:NSStringFromSelector(@selector(servers))];
    }
    return _servers;
}

- (NSUInteger)addServerAddress:(NSString *)address withAccessKey:(NSString *)accessKey {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSMutableDictionary *servers = [[NSMutableDictionary alloc] initWithDictionary:[self servers]];
    [servers setValue:accessKey forKey:address];
    [self setServers:servers];
    return servers.count;
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

@end
