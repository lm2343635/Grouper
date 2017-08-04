//
//  ReceiveTool.m
//  GroupFinance
//
//  Created by lidaye on 30/12/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "ReceiverManager.h"
#import "NetManager.h"
#import "SenderManager.h"

#include "GLibFacade.h"
#include "shamir.h"
#import "DEBUG.h"

@implementation ReceiverManager {
    NetManager *net;
    SenderManager *send;
    GroupManager *group;
    CoreDaoManager *dao;
    SyncManager *sync;
    
    // Number of untrusted servers which are received.
    int received;
    
    NSMutableArray *contents;
    SyncCompletion syncCompletion;
    
    // Processing time statistic obejct.
    Processing *processing;
}

+ (instancetype)sharedInstance {
    static ReceiverManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ReceiverManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        net = [NetManager sharedInstance];
        send = [SenderManager sharedInstance];
        group = [GroupManager sharedInstance];
        dao = [CoreDaoManager sharedInstance];
    }
    return self;
}

- (void)initSyncManager:(DataStack *)stack {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    sync = [[SyncManager alloc] initWithDataStack:stack];
}

// If new share content has been received, regardless of success and fail, revoke this method.
- (void)receivedContent {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    received++;
    if (received == net.managers.count) {
        if (DEBUG || PERFORMANCE_TEST) {
            NSLog(@"All shares has been received successfuly.");
        }
        [self recoverShares];
    }
}

// Receive share and handle message.
- (void)receiveWithCompletion:(SyncCompletion)completion {
    if (DEBUG || PERFORMANCE_TEST) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }

    
    syncCompletion = completion;
    // Only initail finished group can receive shares.
    if (group.defaults.initial != InitialFinished) {
        return;
    }
    
    received = 0;
    contents = [[NSMutableArray alloc] init];
    
    // Download share id list from untrusted servers.
    for (NSString *address in net.managers.allKeys) {
        [net.managers[address] GET:[NetManager createUrl:@"transfer/list" withServerAddress:address]
                    parameters:nil
                      progress:nil
                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                           InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                           if ([response statusOK]) {
                               NSArray *shareIds = [[response getResponseResult] valueForKey:@"shares"];
                               [self downloadSharesWithIds:shareIds fromServer:address];
                           }
                       }
                       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                           InternetResponse *response = [[InternetResponse alloc] initWithError:error];
                           switch ([response errorCode]) {
                               default:
                                   break;
                           }
                           [self receivedContent];
                       }];
    }

}

- (void)downloadSharesWithIds:(NSArray *)ids fromServer:(NSString *)address {
    if (DEBUG) {
        NSLog(@"Running %@ '%@', download share from %@", self.class, NSStringFromSelector(_cmd), address);
    }
    // If there is no share id, return and received plus 1.
    if (ids.count == 0 || ids == nil) {
        [self receivedContent];
        return;
    }
    // Compare with local share id table, discard those downloaded.
    NSArray *shares = [dao.shareDao findInShareIds:ids];
    NSMutableArray *shareIds = [[NSMutableArray alloc] init];
    for (NSString *shareId in ids) {
        if (![self shareId:shareId existInShares:shares]) {
            [shareIds addObject:shareId];
        }
    }
    
    // If there is no share id after checking, return and received plus 1.
    if (shareIds.count == 0 || shareIds == nil) {
        [self receivedContent];
        return;
    }
    
    
    // Download share contents if there is any share id.
    [net.managers[address] POST:[NetManager createUrl:@"transfer/get" withServerAddress:address]
                 parameters:[NSDictionary dictionaryWithObjectsAndKeys: [NSSet setWithArray:shareIds], @"id", nil]
                   progress:nil
                    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                        if ([response statusOK]) {
                            [contents addObjectsFromArray:[[response getResponseResult] valueForKey:@"contents"]];
                            [self receivedContent];
                        }
                    }
                    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        InternetResponse *response = [[InternetResponse alloc] initWithError:error];
                        switch ([response errorCode]) {
                            default:
                                break;
                        }
                        [self receivedContent];
                    }];
}

- (BOOL)shareId:(NSString *)shareId existInShares:(NSArray *)shares {
    for (Share *share in shares) {
        if ([share.shareId isEqualToString:shareId]) {
            return YES;
        }
    }
    return NO;
}

- (void)recoverShares {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (contents.count == 0) {
        syncCompletion();
        return;
    }
    
    NSMutableDictionary *contentGroups = [[NSMutableDictionary alloc] init];
    for (NSObject *content in contents) {
        NSString *messageId = [[content valueForKey:@"data"] valueForKey:@"messageId"];
        NSMutableArray *contentGroup = [contentGroups objectForKey:messageId];
        // If there is no content group with this messageId in groups, create a new one.
        if (contentGroup == nil) {
            contentGroup = [[NSMutableArray alloc] init];
        }
        [contentGroup addObject:content];
        [contentGroups setObject:contentGroup forKey:messageId];
    }
    if (DEBUG || PERFORMANCE_TEST) {
        NSLog(@"Start to recover shares.");
    }
    
    for (NSString *messageId in contentGroups.allKeys) {
        NSArray *contentGroup = contentGroups[messageId];
        // Skip if number of data is less than threshold.
        if (contentGroup.count < group.defaults.threshold) {
            continue;
        }
        // Recover shares.
        NSMutableArray *shares = [[NSMutableArray alloc] init];
        for (NSObject *content in contentGroup) {
            // Save share id to persistent store.
            [dao.shareDao saveWithShareId:[content valueForKey:@"id"]];
            // Extract share from content.
            [shares addObject:[[content valueForKey:@"data"] valueForKey:@"share"]];
        }
        NSString *messageString = [self recoverShareWith:shares];
        if (DEBUG) {
            NSLog(@"Message is recovered at %@\n%@", [NSDate date], messageString);
        }
        if (messageString != nil) {
            [self handleMessage:messageString];
        }
    }
}

- (void)handleMessage:(NSString *)messageString {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // Transfer JSON string to dictionary.
    NSDictionary *messageObject = [self parseJSONString:messageString];
    // Create message data object.
    MessageData *messageData = [[MessageData alloc] initWithDictionary:messageObject];
    
    // If sender is not existed in this device, save it to persistent store.
    User *sender = [dao.userDao getByNode:messageData.sender];
    if (sender == nil) {
        [dao.userDao saveWithEmail:messageData.email
                           forName:messageData.name
                            inNode:messageData.sender];
    }
    
    // If message contains object related info, use SyncManager to sync it to persistent store.
    if ([messageData.type isEqualToString:MessageTypeUpdate] ||
        [messageData.type isEqualToString:MessageTypeDelete]) {
        // If sync successfully, message data.
        if ([sync syncMessage:messageData completion:syncCompletion]) {
            // Save message data in Message eneity.
            [dao.messageDao saveWithMessageData:messageData];
        }
    } else if ([messageData.type isEqualToString:MessageTypeConfirm]) {
        NSDictionary *content = [self parseJSONString:messageData.content];
        NSMutableArray *sequences = [content valueForKey:@"sequences"];
        // Remove exsited sequences in persistent store.
        [sequences removeObjectsInArray:[dao.messageDao findExistedSequencesIn:sequences
                                                                    withSender:messageData.sender]];
        [send resend:sequences to:messageData.sender];
        syncCompletion();
        
    } else if ([messageData.type isEqualToString:MessageTypeResend]) {
        NSDictionary *content = [self parseJSONString:messageData.content];
        // If node identifier of receiver is equql to node identifier of current user, resend messages.
        if ([messageData.receiver isEqualToString:group.currentUser.node]) {
            NSArray *sequences = [content valueForKey:@"sequences"];
            // Send existed messages to untrusted server again,
            // so that those members who did not recevied the messages can rececied again.
            [send sendExistedMessages:[dao.messageDao findInSequences:sequences
                                                           withSender:messageData.receiver]];
        }
        syncCompletion();
    }
}

#pragma mark - Service
- (NSDictionary *)parseJSONString:(NSString *)string {
    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding]
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];
    if (error) {
        NSLog(@"Error serialize message %@", error.localizedDescription);
        return nil;
    }
    return dictionary;
}

// Recover shares to a clear text string.
- (NSString *)recoverShareWith:(NSArray *)shares {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSMutableString *strings = [[NSMutableString alloc] init];
    for (NSString *share in shares) {
        [strings appendString:share];
        [strings appendString:@"\n"];
    }
    const char *secret = extract_secret_from_share_strings([strings cStringUsingEncoding:NSUTF8StringEncoding]);
    return [NSString stringWithCString:secret encoding:NSUTF8StringEncoding];
}

@end
