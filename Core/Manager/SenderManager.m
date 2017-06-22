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
#include "GLibFacade.h"
#include "shamir.h"
#import "DEBUG.h"

@implementation SenderManager {
    NetManager *net;
    CoreDaoManager *dao;
    GroupManager *group;
    
    // Number of sent messages
    int sent;

    // Current message.
    Message *message;
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
- (void)update:(SyncEntity *)object {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
//    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:[object hyp_dictionaryUsingRelationshipType:SYNCPropertyMapperRelationshipTypeNone]];
//    if ([NSStringFromClass(object.class) isEqualToString:@"Template"]) {
//        Template *template = (Template *)object;
//        [dictionary setValue:template.classification.remoteID forKey:@"classification_remoteID"];
//        [dictionary setValue:template.shop.remoteID forKey:@"shop_remoteID"];
//        [dictionary setValue:template.account.remoteID forKey:@"account_remoteID"];
//    }
    
    // Transfer sync entity to dictionary.
    NSDictionary *dictionary = [object export]; //[object hyp_dictionaryUsingRelationshipType:SYNCPropertyMapperRelationshipTypeArray];
    // Create update message and save to sender entity.
    message = [dao.messageDao saveWithContent:[self JSONStringFromObject:dictionary]
                                   objectName:NSStringFromClass(object.class)
                                     objectId:object.remoteID
                                         type:MessageTypeUpdate
                                         from:group.currentUser.node
                                           to:@"*"
                                     sequence:[self generateNewSequence]
                                        email:group.currentUser.email
                                         name:group.currentUser.name];
    // At last, we send the update message to multiple untrusted servers.
    [self sendShares];
}

- (void)delete:(SyncEntity *)object {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // At first, we delete the sync entity.
    [group.appDataStack.mainContext deleteObject:object];
    // Saving context method will be revoked in the next method, so here we need not add a saveContext method for deleting object
    // Then, we create a delete message and save to sender entity.
    message = [dao.messageDao saveWithContent:[self JSONStringFromObject:@{@"id": object.remoteID}]
                                   objectName:NSStringFromClass(object.class)
                                     objectId:object.remoteID
                                         type:MessageTypeDelete
                                         from:group.currentUser.node
                                           to:@"*"
                                     sequence:[self generateNewSequence]
                                        email:group.currentUser.email
                                         name:group.currentUser.name];
    // At last, we send the delete message to multiple untrusted servers.
    [self sendShares];
}

- (void)confirm {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSMutableArray *sequences = [[NSMutableArray alloc] init];
    // Find normal messages sent by current user.
    for (Message *normal in [dao.messageDao findNormalWithSender:group.currentUser.node]) {
        [sequences addObject:normal.sequence];
    }
    // Skip if no sequence.
    if (sequences.count == 0) {
        return;
    }
    // Create confirm message by sequences.
    message = [dao.messageDao saveWithContent:[self JSONStringFromObject:@{@"sequences": sequences}]
                                   objectName:nil
                                     objectId:nil
                                         type:MessageTypeConfirm
                                         from:group.currentUser.node
                                           to:@"*"
                                     sequence:[self generateNewSequence]
                                        email:group.currentUser.email
                                         name:group.currentUser.name];
    [self sendShares];
}

- (void)resend:(NSArray *)sequences to:(NSString *)receiver {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // Skip if no sequence.
    if (sequences.count == 0) {
        return;
    }
    // Create resend message by not existed sequences and node identifier.
    message = [dao.messageDao saveWithContent:[self JSONStringFromObject:@{@"sequences": sequences}]
                                   objectName:nil
                                     objectId:nil
                                         type:MessageTypeResend
                                         from:group.currentUser.node
                                           to:receiver
                                     sequence:[self generateNewSequence]
                                        email:group.currentUser.email
                                         name:group.currentUser.name];
    [self sendShares];
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
    
    /**
     Create a mutable dictionary to save messageId-share dictionary for different multiple untrusted servers.
     It's structure should be like this:
     {
        "address of untrusted server 1": {
            "messageId": "share content",
            "messageId": "share content"
        },
        "address of untrusted server 2": {
            "messageId": "share content",
            "messageId": "share content"
        },
     }
     The address is the key of the outer dictionary.
     The messageId is the key of the inner dictionary.
    **/
    NSMutableDictionary *messageIdShares = [[NSMutableDictionary alloc] init];
    for (NSString *address in group.defaults.servers.allKeys) {
        NSMutableDictionary *messageIdShare = [[NSMutableDictionary alloc] init];
        [messageIdShares setObject:messageIdShare forKey:address];
    }
    // Traverse messages will be send, create shares and add them to messageId-share dictionary.
    for (Message *exsited in messages) {
        // Create shares.
        NSDictionary *shares = [self generateSharesWith:[self JSONStringFromObject:[exsited hyp_dictionary]]];
        // Add messageId and shares.
        for (NSString *address in shares.allKeys) {
            [messageIdShares[address] setValue:shares[address]
                                        forKey:exsited.messageId];
        }
    }

    // Get reveiver.
    NSString *receiver = ((Message *)[messages objectAtIndex:0]).receiver;
    
    sent = 0;
    // Send messageId-share dictionary to multiple untrusted sercers.
    for (NSString *address in messageIdShares) {
        NSDictionary *messageIdShare = messageIdShares[address];
        [net.managers[address] POST:[NetManager createUrl:@"transfer/confirm" withServerAddress:address]
                         parameters:[NSDictionary dictionaryWithObjectsAndKeys: [NSSet setWithArray:messageIdShare.allKeys], @"messageId", nil]
                           progress:nil
                            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                                if ([response statusOK]) {
                                    NSObject *result = [response getResponseResult];
                                    NSArray *notExistedMessageIds = [result valueForKey:@"messageIds"];
                                    NSMutableDictionary *sendMessageIdShare = [[NSMutableDictionary alloc] init];
                                    for (NSString *messageId in notExistedMessageIds) {
                                        [sendMessageIdShare setValue:messageIdShare[messageId] forKey:messageId];
                                    }
                                    // Send message-share which is not existed in untrusted servers.
                                    [net.managers[address] POST:[NetManager createUrl:@"transfer/reput" withServerAddress:address]
                                                     parameters:@{
                                                                  /**
                                                                   Transfer messageId-share dictionary to JSON string like this format.
                                                                   {
                                                                   "messageId": "share content",
                                                                   "messageId": "share content"
                                                                   }
                                                                   **/
                                                                  @"shares": [self JSONStringFromObject:sendMessageIdShare],
                                                                  // All messages' receiver should be same. Get a receiver from the first message.
                                                                  @"receiver": receiver
                                                                  }
                                                       progress:nil
                                                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                            InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                                                            if ([response statusOK]) {
                                                                sent++;
                                                                if (sent == net.managers.count) {
                                                                    [self pushRemoteNotification:[NSString stringWithFormat:@"%@ has resent messages to you.", group.currentUser.name]
                                                                                              to:receiver];
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
// Create a json string from an object.
- (NSString *)JSONStringFromObject:(NSObject *)object {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    if (error) {
        NSLog(@"Create json with error: %@", error.localizedDescription);
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

// Send shares by message.
- (void)sendShares {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // Creat json string
    NSString *json = [self JSONStringFromObject:[message hyp_dictionary]];
    if (DEBUG) {
        NSLog(@"Send message to untrusted servers: %@", json);
    }
    // Create shares by secret sharing scheme.
    NSDictionary *shares = [self generateSharesWith:json];

    sent = 0;
    // Send shares to multiple untrusted servers.
    for (NSString *address in net.managers.allKeys) {
        [net.managers[address] POST:[NetManager createUrl:@"transfer/put" withServerAddress:address]
                     parameters:@{
                                  @"share": shares[address],
                                  @"receiver": message.receiver,
                                  @"messageId": message.messageId
                                  }
                       progress:nil
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                            if ([response statusOK]) {
                                if (DEBUG) {
                                    NSLog(@"Sent share %@ in %@", shares[address], [NSDate date]);
                                }
                                sent ++;
                                if (sent == net.managers.count) {
                                    if (DEBUG) {
                                        NSLog(@"%ld shares sent successfully in %@", (unsigned long)net.managers.count, [NSDate date]);
                                    }
                                    // Push remote notification to receiver if this message is a normal message.
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
    NSArray *addresses = group.defaults.servers.allKeys;
    
    const char *secret = [string cStringUsingEncoding:NSUTF8StringEncoding];
    char *shares = generate_share_strings(secret, addresses.count, group.defaults.threshold);
    NSString *result = [NSString stringWithCString:shares encoding:NSUTF8StringEncoding];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[result componentsSeparatedByString:@"\n"]];
    [array removeLastObject];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < addresses.count; i++) {
        [dictionary setValue:[array objectAtIndex:i]
                      forKey:[addresses objectAtIndex:i]];
    }
    
    return dictionary;
}

@end