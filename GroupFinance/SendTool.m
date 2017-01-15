//
//  SendTool.m
//  GroupFinance
//
//  Created by lidaye on 04/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "SendTool.h"
#import "SecretSharing.h"
#import "DaoManager.h"
#import "InternetTool.h"
#import "GroupTool.h"
#import <SYNCPropertyMapper/SYNCPropertyMapper.h>

@implementation SendTool {
    NSDictionary *managers;
    DaoManager *dao;
}

- (instancetype)initWithObject:(NSManagedObject *)object {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self = [super init];
    if (self) {
        dao = [[DaoManager alloc] init];
        _sender = [dao.senderDao saveWithObject:object];
        managers = [InternetTool getSessionManagers];
    }
    return self;
}

- (void)sendShares {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:[_sender hyp_dictionary]
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    if (error) {
        NSLog(@"Create json with error: %@", error.localizedDescription);
        return;
    }
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (DEBUG) {
        NSLog(@"Send message:%@", text);
    }
    NSDictionary *shares = [SecretSharing generateSharesWith:text];
    self.sent = 0;
    [self addObserver:self
           forKeyPath:@"sent"
              options:NSKeyValueObservingOptionOld
              context:nil];

    for (NSString *address in managers.allKeys) {
        [managers[address] POST:[InternetTool createUrl:@"transfer/put" withServerAddress:address]
                     parameters:@{
                                  @"share": shares[address],
                                  @"receiver": @"",
                                  @"mid": _sender.messageId
                                  }
                       progress:nil
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                            if ([response statusOK]) {
                                self.sent ++;
                                if (DEBUG) {
                                    NSLog(@"Sent share %@ in %@", shares[address], [NSDate date]);
                                }
                            }
                        }
                        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                            InternetResponse *response = [[InternetResponse alloc] initWithError:error];
                            switch ([response errorCode]) {
                                default:
                                    break;
                            }
                        }];
    }
    
}

#pragma mark - Key Value Observe
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([keyPath isEqualToString:@"sent"]) {
        if (self.sent == managers.count) {
            [self removeObserver:self forKeyPath:@"sent"];
            if (DEBUG) {
                NSLog(@"%ld shares sent successfully in %@", managers.count, [NSDate date]);
            }
        }
    }
}

@end
