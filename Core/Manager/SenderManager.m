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
    
    // Lock for data sending.
    // Grouper only allow one data sending task at same time.
    BOOL lock;
    
    // Number of sent messages and sent failed messages
    int sent, failed;
    
    // Processing time statistic obejct.
    Processing *processing;
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
        completion(nil);
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
    [self sendShares:messages withCompletion:completion];
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
    // Save delection to persistent store.
    [group.appDataStack.mainContext save:nil];
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
    [self sendShares:[NSArray arrayWithObject:message]];
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
    [self sendShares:[NSArray arrayWithObject:message]];
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
    [self sendShares:messages];
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
    
    sent = 0;
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
                                    [self sendShares:notExistedMessages];
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
    [self sendShares:messages withCompletion:nil];
}

- (void)sendShares:(NSArray *)messages withCompletion:(SendCompletion)completion {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // Finish data sync.
    [processing dataSynchronized];
    
    NSMutableArray *sharesGroup = [[NSMutableArray alloc] init];
    for (Message *message in messages) {
        // Creat json string
        NSString *json = [self JSONStringFromObject:[message hyp_dictionary]];
        // Create shares by secret sharing scheme.
        [sharesGroup addObject:[self generateSharesWith:json]];
    }

    // Create shares successfully.
    [processing secretSharing];
    
    sent = failed = 0;
    NSArray *addresses = group.defaults.servers;
    // Send shares to multiple untrusted servers.
    for (int i = 0; i < group.defaults.serverCount; i++) {
        NSString *address = addresses[i];
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
                        
                                if (sent == group.defaults.serverCount) {
                                    // Network finished.
                                    [processing networkFinished];
                                    // Callback function with processing object.
                                    completion(processing);
                                    // Release lock.
                                    lock = NO;
                                    
                                    if (DEBUG) {
                                        NSLog(@"Data sending finished, %@", processing.description);
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
                                        [self pushRemoteNotification:[NSString stringWithFormat:@"Click to receive %lu messages", (unsigned long)messages.count]
                                                                  to:message.receiver];
                                    }
                                }
                            }
                        }
                        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                            InternetResponse *response = [[InternetResponse alloc] initWithError:error];
                            switch ([response errorCode]) {
                                default:
                                    failed ++;
                                    // Send shares to untrusted servers failed, save messageId to messageIdQueue
                                    if (failed == group.defaults.threshold) {
                                        NSMutableArray *messageIds = [NSMutableArray arrayWithArray:group.defaults.unsentMessageIds];
                                        for (Message *message in messages) {
                                            if (![messageIds containsObject:message.messageId]) {
                                                [messageIds addObject:message.messageId];
                                            }
                                        }
                                        group.defaults.unsentMessageIds = messageIds;
                                        return;
                                    }
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
