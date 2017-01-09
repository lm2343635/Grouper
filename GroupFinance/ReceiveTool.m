//
//  ReceiveTool.m
//  GroupFinance
//
//  Created by lidaye on 30/12/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "ReceiveTool.h"
#import "GroupTool.h"
#import "DaoManager.h"
#import "InternetTool.h"
#import "SecretSharing.h"
#import "GroupFinance-Swift.h"

@implementation ReceiveTool {
    GroupTool *group;
    DaoManager *dao;
    NSDictionary *managers;
    NSMutableArray *contentsGroup;
    SyncTool *sync;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        managers = [InternetTool getSessionManagers];
        group = [[GroupTool alloc] init];
        dao = [[DaoManager alloc] init];
        sync = [[SyncTool alloc] initWithDataStack:[dao getDataStack]];
    }
    return self;
}

- (void)receive {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    //Only initail finished group can receive shares.
    if (group.initial != InitialFinished) {
        return;
    }
    self.received = 0;
    [self addObserver:self
           forKeyPath:@"received"
              options:NSKeyValueObservingOptionOld
              context:nil];
    contentsGroup = [[NSMutableArray alloc] init];
    [self getIdList];
}

- (void)getIdList {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }

    for (NSString *address in group.servers.allKeys) {
        [managers[address] GET:[InternetTool createUrl:@"transfer/list" withServerAddress:address]
                    parameters:nil
                      progress:nil
                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                           InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                           if ([response statusOK]) {
                               NSArray *ids = [[response getResponseResult] valueForKey:@"shares"];
                               [self downloadSharesWithIds:ids fromServer:address];
                           }
                       }
                       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                           InternetResponse *response = [[InternetResponse alloc] initWithError:error];
                           switch ([response errorCode]) {
                               case ErrorAccessKey:
                                   
                                   break;
                               default:
                                   break;
                           }
                       }];
    }

}

- (void)downloadSharesWithIds:(NSArray *)ids fromServer:(NSString *)address {
    if(DEBUG) {
        NSLog(@"Running %@ '%@', download share from %@", self.class, NSStringFromSelector(_cmd), address);
    }
    //Compare with local id table, discard those downloaded.
    //TODO List
    
    if (ids.count == 0 || ids == nil) {
        self.received++;
        return;
    }
    //Download share contents.
    [managers[address] POST:[InternetTool createUrl:@"transfer/get" withServerAddress:address]
                 parameters:[NSDictionary dictionaryWithObjectsAndKeys: [NSSet setWithArray:ids], @"id", nil]
                   progress:nil
                    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                        if ([response statusOK]) {
                            NSMutableArray *contents = [[response getResponseResult] valueForKey:@"contents"];
                            [contentsGroup addObject:contents];
                            self.received++;
                        }
                    }
                    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        InternetResponse *response = [[InternetResponse alloc] initWithError:error];
                        switch ([response errorCode]) {
                            case ErrorAccessKey:
                                
                                break;
                            default:
                                break;
                        }
                    }];
}

- (void)recoverShares {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (contentsGroup.count == 0) {
        return;
    }
    NSMutableArray *contents0 = [contentsGroup objectAtIndex:0];
    for (NSObject *content in contents0) {
        NSMutableArray *shares = [[NSMutableArray alloc] init];
        NSObject *data = [content valueForKey:@"data"];
        NSString *mid = [data valueForKey:@"mid"];
        [shares addObject:[data valueForKey:@"share"]];
        for (int index = 1; index < contentsGroup.count; index++) {
            NSObject *pairedContent = [self pushPairedContentFrom:index withMessageId:mid];
            [shares addObject:[[pairedContent valueForKey:@"data"] valueForKey:@"share"]];
            //If got enough shares, recover them.
            if (shares.count == group.threshold) {
                break;
            }
        }
        NSString *message = [SecretSharing recoverShareWith:shares];
        [sync syncWithMessage:message];
    }
}

- (NSObject *)pushPairedContentFrom:(NSUInteger)index withMessageId:(NSString *)mid {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSMutableArray *contents = [contentsGroup objectAtIndex:index];
    for (NSObject *content in contents) {
        NSObject *data = [content valueForKey:@"data"];
        if ([mid isEqualToString:[data valueForKey:@"mid"]]) {
            return content;
        }
    }
    return nil;
}

#pragma mark - Key Value Observe
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([keyPath isEqualToString:@"received"]) {
        if (self.received == managers.count) {
            if (DEBUG) {
                NSLog(@"%ld group of shares received successfully in %@", managers.count, [NSDate date]);
            }
            [self removeObserver:self forKeyPath:@"received"];
            [self recoverShares];
        }
    }
}

@end
