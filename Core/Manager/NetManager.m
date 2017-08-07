//
//  InternetTool.m
//  GroupFinance
//
//  Created by 李大爷的电脑 on 06/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "NetManager.h"
#import "GroupManager.h"
#import "DEBUG.h"

@implementation NetManager {
    Defaults *defaults;
}

+ (instancetype)sharedInstance {
    static NetManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NetManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        defaults = [Defaults sharedInstance];
        [self refreshSessionManagers];
    }
    return self;
}

#pragma mark - AFNetworking
@synthesize managers = _managers;

- (NSDictionary *)managers {
    if (_managers == nil) {
        [self refreshSessionManagers];
    }
    return _managers;
}

- (void)refreshSessionManagers {
    NSMutableDictionary *managers = [[NSMutableDictionary alloc] init];
    
    for (int i = 0; i < defaults.servers.count; i++) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        //Set access key in request header.
        [manager.requestSerializer setValue:defaults.keys[i] forHTTPHeaderField:@"key"];
        manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
        [managers setObject:manager forKey:defaults.servers[i]];
    }
    _managers = managers;
}

@synthesize manager = _manager;

- (AFHTTPSessionManager *)manager {
    if(_manager == nil) {
        _manager = [AFHTTPSessionManager manager];
        _manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    }
    return _manager;
}

- (AFHTTPSessionManager *)getSessionManagerWithServerAddress:(NSString *)address {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [_managers objectForKey:address];
}

+ (NSString *)createUrl:(NSString *)relativePosition withServerAddress:(NSString *)address {
    NSString *url=[NSString stringWithFormat:@"http://%@/%@", address, relativePosition];
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
        NSLog(@"Request URL is: %@",url);
    }
    return url;
}

+ (NSDictionary *)getResponse:(id)responseObject {
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:NSJSONReadingAllowFragments
                                                               error:nil];
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
        NSLog(@"Get Message from server: %@", response);
    }
    return response;
}

@end
