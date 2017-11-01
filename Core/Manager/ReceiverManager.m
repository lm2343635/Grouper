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
    
    // Lock for data receiving.
    // Grouper only allow one data receiving task at same time.
    BOOL lock;
    
    // Number of untrusted servers which are received.
    int received;
    
    // Numbers of messages which are handled.
    int handled;
    
    // Share contents received from untrusted servers.
    NSMutableArray *contents;
    
    // Messages strings recovered from shares.
    // messageStrings.count <= contents.count
    NSMutableArray *messageStrings;
    
    ReceiveCompletion receiveCompletion;
    
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

// Receive share and handle message.
- (void)receiveWithCompletion:(ReceiveCompletion)completion {
    if (DEBUG || PERFORMANCE_TEST) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (lock) {
        completion(0, nil);
        return;
    }
    
    // Lock data receiving process.
    lock = YES;
    // Start statistic for data receiving.
    processing = [[Processing alloc] initWithType:Receiving];
    
    receiveCompletion = completion;
    // Only initail finished group can receive shares.
    if (group.defaults.initial != InitialFinished) {
        return;
    }
    
    received = 0;
    contents = [[NSMutableArray alloc] init];
    
    NSArray *addresses = group.defaults.servers;
    // Download share id list from untrusted servers.
    for (int i = 0; i < group.defaults.serverCount; i++) {
        NSString *address = addresses[i];
        [net.managers[address] GET:[NetManager createUrl:@"transfer/list" withServerAddress:address]
                    parameters:nil
                      progress:nil
                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                           InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                           if ([response statusOK]) {
                               // Get shareId list.
                               NSArray *shareIds = [[response getResponseResult] valueForKey:@"shares"];
                               // Download share content by shareId list.
                               [self downloadSharesWithIds:shareIds fromServer:address];
                           }
                       }
                       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                           InternetResponse *response = [[InternetResponse alloc] initWithError:error];
                           switch ([response errorCode]) {
                               default:
                                   [self received];
                                   break;
                           }
                       }];
    }

}

- (void)downloadSharesWithIds:(NSArray *)ids fromServer:(NSString *)address {
    if (DEBUG) {
        NSLog(@"Running %@ '%@', download share from %@", self.class, NSStringFromSelector(_cmd), address);
    }
    // If there is no share id, return and received plus 1.
    if (ids.count == 0 || ids == nil) {
        [self received];
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
        [self received];
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
                            [self received];
                        }
                    }
                    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        InternetResponse *response = [[InternetResponse alloc] initWithError:error];
                        switch ([response errorCode]) {
                            default:
                                [self received];
                                break;
                        }
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

// Recover shares to messages.
- (void)recoverShares {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // If there is not shares, finish data receving directly.
    if (contents.count == 0) {
        [processing directFinish];
        receiveCompletion(0, processing);
        // Release data receiving lock.
        lock = NO;
        return;
    }
    
    // Classify shares by its messageId.
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
    
    // Start to recover shares.
    messageStrings = [[NSMutableArray alloc] init];
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
        // If message string is not nil, add it to array.
        if (messageString != nil) {
            [messageStrings addObject:messageString];
        }
    }
    
    // All messages has been recoverd by secret sharing.
    [processing secretSharing];
    [self handleMessages];
    
}

- (void)handleMessages {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (messageStrings.count == 0) {
        [processing directFinish];
        receiveCompletion(0, processing);
        // Release data receiving lock.
        lock = NO;
        return;
    }
    handled = 0;
    for (NSString *string in messageStrings) {
        // Transfer JSON string to dictionary.
        NSDictionary *messageObject = [self parseJSONString:string];
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
            [sync syncMessage:messageData completion:^(BOOL success) {
                // If sync successfully, save message data in Message eneity.
                if (success) {
                    [dao.messageDao saveWithMessageData:messageData];
                }
                [self handled];
            }];
        } else if ([messageData.type isEqualToString:MessageTypeConfirm]) {
            NSDictionary *content = [self parseJSONString:messageData.content];
            int maxSequence = [[content valueForKey:@"sequence"] intValue];
            Message *localMessageWithMaxSequence = [dao.messageDao getNormalWithMaxSquenceForSender:group.currentUser.node];
            int localMaxSequence = localMessageWithMaxSequence.sequence.intValue;
            // If the remote max sequence is larger than the local max sequence number,
            // Send a confirm message with the rage from local max sequence + 1 to remote sequence number.
            if (maxSequence > localMaxSequence) {
                [send resendWith:localMaxSequence + 1 and:maxSequence to:messageData.sender];
            }
            [self handled];
        } else if ([messageData.type isEqualToString:MessageTypeResend]) {
            NSDictionary *content = [self parseJSONString:messageData.content];
            // If the node identifier of the receiver is equql to the node identifier of the current user, resend messages.
            if ([messageData.receiver isEqualToString:group.currentUser.node]) {
                NSNumber *min = [content valueForKey:@"min"];
                NSNumber *max = [content valueForKey:@"max"];
                NSArray *existedMessages = [dao.messageDao findWithSequenceFrom:min to:max for:messageData.receiver];
                // Send existed messages to untrusted servers again,
                // so that those members who did not recevied the messages can rececied again.
                [send sendExistedMessages:existedMessages];
            }
            [self handled];
        }
    }
    
}

#pragma mark - Counter
// Invoke this method if new share content has been received from one server, regardless of success and fail.
- (void)received {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    received++;
    if (received == group.defaults.serverCount) {
        if (DEBUG || PERFORMANCE_TEST) {
            NSLog(@"All shares has been received successfuly.");
        }
        [processing networkFinished];
        [self recoverShares];
    }
}

// Invoke this method if one message has been handled, regardless of success and fail.
- (void)handled {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    handled++;
    // If all message strings has been handled, invoke the receiveCompletion callback function.
    if (handled == messageStrings.count) {
        if (DEBUG || PERFORMANCE_TEST) {
            NSLog(@"All messages has been handled successfuly.");
        }
        [processing dataSynchronized];
        receiveCompletion(messageStrings.count, processing);
        // Release data receiving lock.
        lock = NO;
    }
}

#pragma mark - Service
// Parse JSON string to dictionary.
- (NSDictionary *)parseJSONString:(NSString *)string {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
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
