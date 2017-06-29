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
- (void)update:(NSArray *)entities {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    for (NSManagedObject *object in entities) {
        SyncEntity *entity = (SyncEntity *)object;
        
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
        Message *message = [dao.messageDao saveWithContent:[self JSONStringFromObject:dictionary]
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
    [self sendShares:messages];
}

- (void)delete:(NSArray *)entitys {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    for (SyncEntity *entity in entitys) {
        // At first, we delete the sync entity.
        [group.appDataStack.mainContext deleteObject:entity];
        
        // Saving context method will be revoked in the next method, so here we need not add a saveContext method for deleting object
        // Then, we create a delete message and save to sender entity.
        Message *message = [dao.messageDao saveWithContent:[self JSONStringFromObject:@{@"id": entity.remoteID}]
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
    // At last, we send the delete message to multiple untrusted servers.
    [self sendShares:messages];
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
    Message *message = [dao.messageDao saveWithContent:[self JSONStringFromObject:@{@"sequences": sequences}]
                                   objectName:nil
                                     objectId:nil
                                         type:MessageTypeConfirm
                                         from:group.currentUser.node
                                           to:@"*"
                                     sequence:[self generateNewSequence]
                                        email:group.currentUser.email
                                         name:group.currentUser.name];
//    [self sendShares];
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
    Message *message = [dao.messageDao saveWithContent:[self JSONStringFromObject:@{@"sequences": sequences}]
                                   objectName:nil
                                     objectId:nil
                                         type:MessageTypeResend
                                         from:group.currentUser.node
                                           to:receiver
                                     sequence:[self generateNewSequence]
                                        email:group.currentUser.email
                                         name:group.currentUser.name];
//    [self sendShares];
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
- (void)sendShares:(NSArray *)messages {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }

    NSMutableArray *sharesGroup = [[NSMutableArray alloc] init];
    for (Message *message in messages) {
        // Creat json string
        NSString *json = [self JSONStringFromObject:[message hyp_dictionary]];
        // Create shares by secret sharing scheme.
        [sharesGroup addObject:[self generateSharesWith:json]];
    }
    if (DEBUG) {
        NSLog(@"Create shares successfully: %@", sharesGroup);
    }
    
    sent = 0;
    // Send shares to multiple untrusted servers.
    for (NSString *address in net.managers.allKeys) {
        NSMutableArray *shares = [[NSMutableArray alloc] init];
        // Create JSON parameter.
        for (int i = 0; i < messages.count; i++) {
            Message *message = [messages objectAtIndex:i];
            [shares addObject:@{
                                @"share": [[sharesGroup objectAtIndex:i] valueForKey:address],
                                @"receiver": message.receiver,
                                @"messageId": message.messageId
                                }];
        }
        
        [net.managers[address] POST:[NetManager createUrl:@"transfer/put" withServerAddress:address]
                     parameters:@{@"shares": [self JSONStringFromObject:shares]}
                       progress:nil
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                            if ([response statusOK]) {
                                sent ++;
                                if (sent == net.managers.count) {
                                    if (DEBUG) {
                                        NSLog(@"%d shares has been sent successfully.", net.managers.count * messages.count);
                                    }
                                    // Push remote notification.
                                    Message *message = [messages objectAtIndex:0];
                                    if (messages.count == 1) {
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
                                        [self pushRemoteNotification:[NSString stringWithFormat:@"Click to receive %d messages", messages.count]
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
