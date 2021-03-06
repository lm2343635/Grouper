//
//  SendTool.m
//  GroupFinance
//
//  Created by lidaye on 04/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "SenderManager.h"
#import "NetManager.h"
#import "GroupManager.h"
#import "SharesQueue.h"
#include "GLibFacade.h"
#include "shamir.h"
#import "DEBUG.h"

@implementation SenderManager {
    NetManager *net;
    CoreDaoManager *dao;
    GroupManager *group;
    
    // Lock for data sending.
    // Grouper only allow one data sending task at same time.
    BOOL lock;
    
    NSMutableDictionary *sharesQueues;
    
    // Processing time statistic obejct.
    Processing *processing;
    
    NSArray *sendingMessages;
    SendCompletion sendingCompletion;
    int sendingServersCount, successServersCount;
}

+ (instancetype)sharedInstance {
    static SenderManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SenderManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self = [super init];
    if (self) {
        net = [NetManager sharedInstance];
        dao = [CoreDaoManager sharedInstance];
        group = [GroupManager sharedInstance];
    }
    return self;
}

#pragma mark - Create message and send shares to untrusted servers.

- (void)update:(NSManagedObject *)entity {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self updateAll:[NSArray arrayWithObject:(SyncEntity *)entity]];
}

- (void)delete:(NSManagedObject *)entity {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self deleteAll:[NSArray arrayWithObject:(SyncEntity *)entity]];
}

- (void)updateAll:(NSArray *)entities {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self updateAll:entities withCompletion:nil];
}

- (void)updateAll:(NSArray *)entities withCompletion:(SendCompletion)completion {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // If sending task is running now, do not allow to open a new sending task.
    if (lock) {
        completion(nil, NO);
        return;
    }
    lock = YES;
    // Init a processing object.
    processing = [[Processing alloc] initWithType:Sending];
    
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    for (SyncEntity *entity in entities) {
        
        // If this sync entity has no remoteID, it is a new created sync entity.
        // Set remoteID, createor and create date for this entity.
        if (entity.remoteID == nil) {
            entity.remoteID = [[NSUUID UUID] UUIDString];
            entity.createAt = [NSDate date];
            entity.creator = group.currentUser.node;
        }
        
        // Update update date and updater of this entity.
        entity.updateAt = [NSDate date];
        entity.updator = group.currentUser.node;
        // Save entity to app's persistent store.
        [group saveAppContext];
        
        // Transfer sync entity to dictionary.
        NSDictionary *dictionary = [entity export]; //[object hyp_dictionaryUsingRelationshipType:SYNCPropertyMapperRelationshipTypeArray];
        // Create update message and save to sender entity.
        Message *message = [dao.messageDao saveWithContent:[group JSONStringFromObject:dictionary]
                                                objectName:NSStringFromClass(entity.class)
                                                  objectId:entity.remoteID
                                                      type:MessageTypeUpdate
                                                      from:group.currentUser.node
                                                        to:@"*"
                                                  sequence:[self generateNewSequence]
                                                     email:group.currentUser.email
                                                      name:group.currentUser.name];
        [messages addObject:message];
    }
    
    // At last, we send the update message to multiple untrusted servers.
    sendingCompletion = completion;
    [self sendMessages:messages];
}

- (void)deleteAll:(NSArray *)entitys {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    for (SyncEntity *entity in entitys) {
        // At first, we delete the sync entity.
        [group.appDataStack.mainContext deleteObject:entity];
        
        // Saving context method will be revoked in the next method, so here we need not add a saveContext method for deleting object
        // Then, we create a delete message and save to sender entity.
        Message *message = [dao.messageDao saveWithContent:[group JSONStringFromObject:@{@"id": entity.remoteID}]
                                                objectName:NSStringFromClass(entity.class)
                                                  objectId:entity.remoteID
                                                      type:MessageTypeDelete
                                                      from:group.currentUser.node
                                                        to:@"*"
                                                  sequence:[self generateNewSequence]
                                                     email:group.currentUser.email
                                                      name:group.currentUser.name];
        [messages addObject:message];
    }
    // Save delection to persistent store.
    [group.appDataStack.mainContext save:nil];
    // At last, we send the delete message to multiple untrusted servers.
    [self sendMessages:messages];
}

- (void)confirm {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    // Find the normal message with the max sequence number sent by current user.
    Message *normalMessageWithMaxSeq = [dao.messageDao getNormalWithMaxSquenceForSender:group.currentUser.node];
    // Skip if no message found.
    if (normalMessageWithMaxSeq == nil) {
        return;
    }
    // Create confirm message by sequences.
    Message *message = [dao.messageDao saveWithContent:[group JSONStringFromObject:@{@"sequence": normalMessageWithMaxSeq.sequence}]
                                   objectName:nil
                                     objectId:nil
                                         type:MessageTypeConfirm
                                         from:group.currentUser.node
                                           to:@"*"
                                     sequence:0
                                        email:group.currentUser.email
                                         name:group.currentUser.name];
    [self sendMessages:[NSArray arrayWithObject:message]];
}

- (void)resendWith:(int)min and:(int)max to:(NSString *)receiver {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    // Skip if no sequence.
    if (max < min) {
        return;
    }
    // Create resend message by not existed sequences and node identifier.
    Message *message = [dao.messageDao saveWithContent:[group JSONStringFromObject:@{
                                                                                     @"min": [NSNumber numberWithInt:min],
                                                                                     @"max": [NSNumber numberWithInt:max]
                                                                                     }]
                                   objectName:nil
                                     objectId:nil
                                         type:MessageTypeResend
                                         from:group.currentUser.node
                                           to:receiver
                                     sequence:0
                                        email:group.currentUser.email
                                         name:group.currentUser.name];
    [self sendMessages:[NSArray arrayWithObject:message]];
}

- (void)unsent {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    if (group.defaults.unsentMessageIds == nil) {
        return;
    }
    // Find unsent messages by unsentMessageIds.
    NSArray *messages = [dao.messageDao findInMessageIds:group.defaults.unsentMessageIds];
    // Clear unsent messagesId.
    group.defaults.unsentMessageIds = nil;
    [self sendMessages:messages];
}

#pragma mark - Send existed messages.

// Send existed messages.
- (void)sendExistedMessages:(NSArray *)messages {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    // If there is no messages, end the method.
    if (messages.count == 0) {
        return;
    }
    
    NSMutableDictionary *idMessage = [[NSMutableDictionary alloc] init];
    for (Message *message in messages) {
        [idMessage setObject:message forKey:message.messageId];
    }

    // Send messageId-share dictionary to multiple untrusted sercers.
    for (NSString *address in net.managers.allKeys) {
        [net.managers[address] POST:[NetManager createUrl:@"transfer/confirm" withServerAddress:address]
                         parameters:[NSDictionary dictionaryWithObjectsAndKeys: idMessage.allKeys, @"messageId", nil]
                           progress:nil
                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                                if ([response statusOK]) {
                                    NSObject *result = [response getResponseResult];
                                    NSArray *notExistedMessageIds = [result valueForKey:@"messageIds"];
                                    NSMutableArray *notExistedMessages = [[NSMutableArray alloc] init];
                                    for (NSString *messageId in notExistedMessageIds) {
                                        [notExistedMessages addObject:idMessage[messageId]];
                                    }
                                    [self sendMessages:notExistedMessages];
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


#pragma mark - Service

- (void)sendMessages:(NSArray *)messages {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    sendingMessages = messages;
    
    // Finish data sync.
    [processing dataSynchronized];
    
    NSMutableArray *sharesGroup = [[NSMutableArray alloc] init];
    for (Message *message in messages) {
        // Creat json string
        NSString *json = [group JSONStringFromObject:[message hyp_dictionary]];
        if (DEBUG) {
            NSLog(@"Send message: %@", json);
        }
        // Create shares by secret sharing scheme.
        [sharesGroup addObject:[self generateSharesWith:json]];
    }

    // Create shares successfully.
    [processing secretSharing];
    
    NSArray *addresses = group.defaults.servers;
    // Init sharesQueues dictionary.
    sharesQueues = [[NSMutableDictionary alloc] init];
    sendingServersCount = group.defaults.serverCount;
    successServersCount = 0;

    // Send shares to multiple untrusted servers.
    for (int i = 0; i < group.defaults.serverCount; i++) {
        NSString *address = addresses[i];
        NSMutableArray *shares = [[NSMutableArray alloc] init];
        int count = 0;
        
        NSMutableArray *sharesQueue = [[NSMutableArray alloc] init];
        // Create JSON parameter.
        for (int i = 0; i < messages.count; i++) {
            Message *message = [messages objectAtIndex:i];
            [shares addObject:@{
                                @"share": [[sharesGroup objectAtIndex:i] valueForKey:address],
                                @"receiver": message.receiver,
                                @"messageId": message.messageId
                                }];
            count++;
            // If there the number of messages in a shares array is ShareSendingStep,
            // or all messages has been added to the shares array,
            // send this shares array at first.
            if (count % ShareSendingStep == 0 || i == messages.count - 1) {
                // Put the the JSON string of shares into queue.
                [sharesQueue addObject:[group JSONStringFromObject:shares]];
                // Clear the shares array.
                [shares removeAllObjects];
            }
        }
        // Prepare the sharesQueue dictionary.
        [sharesQueues setValue:[[SharesQueue alloc] initWithQueue:sharesQueue]
                        forKey:address];
        
        // Send the first JSON string of shares to the untrusted server.
        [self sendSharesTo:address];
    }
}

- (void)sendSharesTo:(NSString *)address {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    SharesQueue *sharesQueue = [sharesQueues valueForKey:address];
    NSString *share = [sharesQueue dequeue];
    // NSLog(@"share = %@, state = %d", share, sharesQueue.state);
    if (share == nil) {
        sharesQueue.state = SharesSuccess;
        [sharesQueues setValue:sharesQueue forKey:address];
        [self sentTo:address withResult:true];
        return;
    }
    if (sharesQueue.state != SharesSending) {
        [self sentTo:address withResult:false];
        return;
    }
    [net.managers[address] POST:[NetManager createUrl:@"transfer/put" withServerAddress:address]
                     parameters:@{@"shares": share}
                       progress:nil
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                            // Use the response status as the success flag.
                            // If the response status code is 200, we regard this share uploading successful.
                            [self sentTo:address withResult:[response statusOK]];
                        }
                        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                            InternetResponse *response = [[InternetResponse alloc] initWithError:error];
                            switch ([response errorCode]) {
                                default:
                                    [self sentTo:address withResult:false];
                                    break;
                            }
                        }];
}

/**
 Hanlde the result of a HTTP request.
 
 The number of all HTTP requests should plus 1 after invoking this method,
 if all requests has been sent, try to confirm the number of servers which are accessed successfully.
 We reagrd that a server is accessed successfully only in the situation that all HTTP requests of this server have been sent sucessfully.
 If the number of servers which are acceessed successfully is larger than s, we regard this share uploading successful.
 **/
- (void)sentTo:(NSString *)address withResult:(BOOL)success {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    // Get shareQueue object from dictionary.
    SharesQueue *sharesQueue = [sharesQueues valueForKey:address];
    
    // NSLog(@"sendingServersCount = %d, successServersCount = %d, success = %d, state = %d", sendingServersCount, successServersCount, success, sharesQueue.state);
    
    if (!success) {
        sharesQueue.state = SharesFailed;
        [sharesQueues setValue:sharesQueue forKey:address];
        sendingServersCount--;
        return;
    }
    
    if (sharesQueue.state == SharesSending) {
        // If one of http requests for an untrusted server is failed, stop the the rest of requests for this server.
        [self sendSharesTo:address];
        return;
    }
    if (sharesQueue.state == SharesStop) {
        return;
    }
    
    // In this situation, sharesQueue.state == SharesSuccess.
    sendingServersCount--;
    successServersCount++;
    if (sendingServersCount == 0) {
        // Network finished.
        [processing networkFinished];
    
        // Release lock.
        lock = NO;
        if (DEBUG) {
            NSLog(@"Data sending finished, %@", processing.description);
            NSLog(@"Data has been sent to %d servers, f(k, n, s) scheme requires %d servers.", successServersCount, group.defaults.safeServerCount);
        }
        
        // If the number of servers which are acceessed successfully is larger than s,
        // we regard this share uploading successful.
        if (successServersCount >= group.defaults.safeServerCount) {
            // Push remote notification.
            [self pushSuccessRemoteNotification];
            // Callback function with processing object.
            if (sendingCompletion != nil) {
                sendingCompletion(processing, YES);
            }
            
        } else {
            // Save the id of messages to unsentMessageIds.
            NSMutableArray *messageIds = [NSMutableArray arrayWithArray:group.defaults.unsentMessageIds];
            for (Message *message in sendingMessages) {
                if (![messageIds containsObject:message.messageId]) {
                    [messageIds addObject:message.messageId];
                }
            }
            group.defaults.unsentMessageIds = messageIds;
            if (sendingCompletion != nil) {
                sendingCompletion(processing, NO);
            }
        }
    }

}

- (void)pushSuccessRemoteNotification {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Message *message = [sendingMessages objectAtIndex:0];
    if (sendingMessages.count == 1) {
        if ([message.type isEqualToString:@"update"]) {
            [self pushRemoteNotification:[NSString stringWithFormat:@"%@ has created or updated a %@.", group.currentUser.name, message.object]
                                      to:@"*"];
        } else if ([message.type isEqualToString:@"delete"]) {
            [self pushRemoteNotification:[NSString stringWithFormat:@"%@ has delete a %@.", group.currentUser.name, message.object]
                                      to:@"*"];
        } else if ([message.type isEqualToString:@"confirm"]) {
            [self pushRemoteNotification:[NSString stringWithFormat:@"%@ ask you to confirm his/her messages.", group.currentUser.name]
                                      to:@"*"];
        } else if ([message.type isEqualToString:@"resend"]) {
            [self pushRemoteNotification:[NSString stringWithFormat:@"%@ ask you to resend your messages.", group.currentUser.name]
                                      to:message.receiver];
        }
    } else {
        [self pushRemoteNotification:[NSString stringWithFormat:@"Click to receive %lu messages", (unsigned long)sendingMessages.count]
                                  to:message.receiver];
    }
}

// Push notification to a receiver with message content.
- (void)pushRemoteNotification:(NSString *)content to:(NSString *)reveiver {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // Select an untrusted server to push remote notification.
    NSString *address0 = [net.managers.allKeys objectAtIndex:0];
    [net.managers[address0] POST:[NetManager createUrl:@"user/notify" withServerAddress:address0]
                  parameters:@{
                               @"content": content,
                               @"receiver": reveiver,
                               @"category": @"message"
                               }
                    progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                         if ([response statusOK]) {

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

// Generate a new sequence for creating new message.
- (NSInteger)generateNewSequence {
    // Get seuqence from defaults and plus 1.
    group.defaults.sequence = group.defaults.sequence + 1;
    // Return new sequence.
    return group.defaults.sequence;
}

// Generate shares with a cleat text string.
- (NSDictionary *)generateSharesWith:(NSString *)string {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSArray *addresses = group.defaults.servers;
    char *secret = (char *)[string cStringUsingEncoding:NSUTF8StringEncoding];
    int n = (int)group.defaults.serverCount;
    int threshold = (int)group.defaults.threshold;
    char *shares = generate_share_strings(secret, n, threshold);
    NSString *result = [NSString stringWithCString:shares encoding:NSUTF8StringEncoding];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[result componentsSeparatedByString:@"\n"]];
    [array removeLastObject];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < n; i++) {
        [dictionary setValue:[array objectAtIndex:i]
                      forKey:[addresses objectAtIndex:i]];
    }
    
    return dictionary;
}

@end
