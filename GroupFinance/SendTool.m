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

#define PARTS 3
#define RECOVER 2

@implementation SendTool {
    int dcount;
}

- (instancetype)initWithSender:(Sender *)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self = [super init];
    if (self) {
        _sender = sender;
    }
    return self;
}

- (void)sendShares {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    AFHTTPSessionManager *manager = [InternetTool getSessionManager];
    NSArray *shares = [SecretSharing generateSharesWith:_sender.content parts:PARTS recover:RECOVER];
    self.sent = 0;
    [self addObserver:self
           forKeyPath:@"sent"
              options:NSKeyValueObservingOptionOld
              context:nil];
    dcount = 0;
    for (NSString *share in shares) {
        [manager POST:[InternetTool createUrl:@"transfer/send"]
           parameters:@{
                        @"sid": _sender.sid,
                        @"content": share,
                        @"object": _sender.object
                        }
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                  self.sent ++;
                  dcount += [[response.data valueForKey:@"count"] intValue];
                  if (DEBUG) {
                      NSLog(@"Sent share %@ in %@", share, [NSDate date]);
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

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([keyPath isEqualToString:@"sent"]) {
        if (self.sent == PARTS) {
            //Set sender time, update count
            _sender.sendtime = [NSDate date];
            _sender.count = [NSNumber numberWithInt:_sender.count.intValue + dcount];
            DaoManager *dao = [[DaoManager alloc] init];
            [dao saveContext];
            [self removeObserver:self forKeyPath:@"sent"];
            if (DEBUG) {
                NSLog(@"%d shares sent successfully in %@", PARTS, [NSDate date]);
            }
        }
    }
}

@end
