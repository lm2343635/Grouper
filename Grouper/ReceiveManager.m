//
//  ReceiveTool.m
//  GroupFinance
//
//  Created by lidaye on 30/12/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "ReceiveManager.h"
#import "NetManager.h"
#import "SendManager.h"
#import "GroupManager.h"
#import "DaoManager.h"
#import "SecretSharing.h"
#import "Grouper-Swift.h"

@implementation ReceiveManager {
    NetManager *net;
    SendManager *send;
    GroupManager *group;
    DaoManager *dao;

    NSMutableArray *contentsGroup;
    SyncTool *sync;
    Completion syncCompletion;
}

+ (instancetype)sharedInstance {
    static ReceiveManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ReceiveManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        net = [NetManager sharedInstance];
        send = [SendManager sharedInstance];
        group = [GroupManager sharedInstance];
        dao = [DaoManager sharedInstance];
        sync = [[SyncTool alloc] initWithDataStack:[dao getDataStack]];
    }
    return self;
}

- (void)dealloc {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    @try {
        [self removeObserver:self forKeyPath:ReceivedTag];
    } @catch(id anException) {
        //do nothing, obviously it wasn't attached because an exception was thrown
    }
}

- (void)receiveWithCompletion:(Completion)completion {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    syncCompletion = completion;
    // Only initail finished group can receive shares.
    if (group.defaults.initial != InitialFinished) {
        return;
    }
    self.received = 0;
    [self addObserver:self
           forKeyPath:ReceivedTag
              options:NSKeyValueObservingOptionOld
              context:nil];
    contentsGroup = [[NSMutableArray alloc] init];
    [self getIdList];
}

- (void)getIdList {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
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
                               case ErrorAccessKey:
                                   
                                   break;
                               default:
                                   break;
                           }
                           self.received ++;
                       }];
    }

}

- (void)downloadSharesWithIds:(NSArray *)ids fromServer:(NSString *)address {
    if(DEBUG) {
        NSLog(@"Running %@ '%@', download share from %@", self.class, NSStringFromSelector(_cmd), address);
    }
    // If there is no share id, return and received plus 1.
    if (ids.count == 0 || ids == nil) {
        self.received ++;
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
        self.received ++;
        return;
    }
    
    // Download share contents if there is any share id.
    [net.managers[address] POST:[NetManager createUrl:@"transfer/get" withServerAddress:address]
                 parameters:[NSDictionary dictionaryWithObjectsAndKeys: [NSSet setWithArray:shareIds], @"id", nil]
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
                        self.received++;
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
    if (contentsGroup.count == 0) {
        syncCompletion();
        return;
    }
    NSMutableArray *contents0 = [contentsGroup objectAtIndex:0];
    for (NSObject *content in contents0) {
        NSMutableArray *shares = [[NSMutableArray alloc] init];
        NSMutableArray *shareIds = [[NSMutableArray alloc] init];
        NSObject *data = [content valueForKey:@"data"];
        // Get messageId
        NSString *messageId = [data valueForKey:@"messageId"];
        [shares addObject:[data valueForKey:@"share"]];
        [shareIds addObject:[content valueForKey:@"id"]];
        // Find other shares with same messageId.
        for (int index = 1; index < contentsGroup.count; index++) {
            NSObject *pairedContent = [self pushPairedContentFrom:index withMessageId:messageId];
            [shares addObject:[[pairedContent valueForKey:@"data"] valueForKey:@"share"]];
            // If got enough shares, only add share id.
            if (shares.count >= group.defaults.threshold) {
                [shareIds addObject:[pairedContent valueForKey:@"id"]];
            }
        }
        // Only getting more than k(threshold) shares, Grouper can recover and sync to persistent store.
        if (shares.count >= group.defaults.threshold) {
            NSString *messageString = [SecretSharing recoverShareWith:shares];
            if (DEBUG) {
                NSLog(@"Message is recovered at %@\n%@", [NSDate date], messageString);
            }
            [self handleMessage:messageString];
            // Save share id in Share entity.
            for (NSString *shareId in shareIds) {
                [dao.shareDao saveWithShareId:shareId];
            }
        }
        syncCompletion();
    }
}

- (void)handleMessage:(NSString *)messageString {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // Transfer JSON string to dictionary.
    NSDictionary *messageObject =[self parseJSONString:messageString];
    // Create message data object.
    MessageData *messageData = [[MessageData alloc] initWithDictionary:messageObject];
    // If message contains object related info, use SyncTool to sync it to persistent store.
    if ([messageData.type isEqualToString:MessageTypeUpdate] ||
        [messageData.type isEqualToString:MessageTypeDelete]) {
        // If sync successfully, message data.
        if ([sync syncWithMessageData: messageData]) {
            // Save message data in Message eneity.
            [dao.messageDao saveWithMessageData:messageData];
        }
    } else if ([messageData.type isEqualToString:MessageTypeConfirm]) {
        NSDictionary *content = [self parseJSONString:messageData.content];
        NSString *node = [content valueForKey:@"node"];
        NSMutableArray *sequences = [content valueForKey:@"sequences"];
        // Remove exsited sequences in persistent store.
        [sequences removeObjectsInArray:[dao.messageDao findExistedSequencesIn:sequences
                                                                      withNode:node]];
        [send resend:sequences forNode:node to:messageData.sender];
        
    } else if ([messageData.type isEqualToString:MessageTypeResend]) {
        NSDictionary *content = [self parseJSONString:messageData.content];
        NSString *node = [content valueForKey:@"node"];
        // If node identifier is same with which in local persistent store, resend messages.
        if ([node isEqualToString:group.defaults.node]) {
            NSArray *sequences = [content valueForKey:@"sequences"];
            // Send existed messages to untrusted server again,
            // so that those members who did not recevied the messages can rececied again.
            [send sendExistedMessages:[dao.messageDao findInSequences:sequences
                                                             withNode:node]];
        }
    }
}

- (NSObject *)pushPairedContentFrom:(NSUInteger)index withMessageId:(NSString *)messageId {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSMutableArray *contents = [contentsGroup objectAtIndex:index];
    for (NSObject *content in contents) {
        NSObject *data = [content valueForKey:@"data"];
        if ([messageId isEqualToString:[data valueForKey:@"messageId"]]) {
            return content;
        }
    }
    return nil;
}

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

#pragma mark - Key Value Observe
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([keyPath isEqualToString:ReceivedTag]) {
        if (DEBUG) {
            NSLog(@"%ld group of shares received.", (long)self.received);
        }
        if (self.received == net.managers.count) {
            if (DEBUG) {
                NSLog(@"All of %ld group of shares received successfully in %@", (unsigned long)net.managers.count, [NSDate date]);
            }
            [self removeObserver:self forKeyPath:ReceivedTag];
            [self recoverShares];
        }
    }
}

@end
