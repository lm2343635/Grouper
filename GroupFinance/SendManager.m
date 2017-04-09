//
//  SendTool.m
//  GroupFinance
//
//  Created by lidaye on 04/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "NetManager.h"
#import "GroupManager.h"
#import "SendManager.h"
#import "SecretSharing.h"
#import <SYNCPropertyMapper/SYNCPropertyMapper.h>

@implementation SendManager {
    NetManager *net;
    DaoManager *dao;
    GroupManager *group;
    
    NSUserDefaults *defaults;

    User *currentUser;
    Message *message;
}

+ (instancetype)sharedInstance {
    static SendManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SendManager alloc] init];
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
        dao = [DaoManager sharedInstance];
        group = [GroupManager sharedInstance];
        
        defaults = [NSUserDefaults standardUserDefaults];
        currentUser = [dao.userDao currentUser];
        [self sequence];
    }
    return self;
}

#pragma mark - Sequence
@synthesize sequence = _sequence;

- (void)setSequence:(NSInteger)sequence {
    _sequence = sequence;
    [defaults setInteger:sequence forKey:NSStringFromSelector(@selector(sequence))];
}

- (NSInteger)sequence {
    if (_sequence == 0) {
        _sequence = [defaults integerForKey:NSStringFromSelector(@selector(sequence))];
    }
    return _sequence;
}

- (NSInteger)generateNewSequence {
    _sequence = _sequence + 1;
    return _sequence;
}

#pragma mark - Create Message
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
    NSDictionary *dictionary = [object hyp_dictionaryUsingRelationshipType:SYNCPropertyMapperRelationshipTypeArray];
    // Create update message and save to sender entity.
    message = [dao.messageDao saveWithContent:[self JSONStringFromObject:dictionary]
                                   objectName:NSStringFromClass(object.class)
                                     objectId:object.remoteID
                                         type:@"update"
                                         from:currentUser.userId
                                           to:@"*"
                                     sequence:[self generateNewSequence]
                                         node:group.defaults.node];
    // At last, we send the update message to multiple untrusted servers.
    [self sendShares];
}

- (void)delete:(SyncEntity *)object {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // At first, we delete the sync entity.
    [dao.context deleteObject:object];
    // Saving context method will be revoked in the next method, so here we need not add a saveContext method for deleting object
    // Then, we create a delete message and save to sender entity.
    message = [dao.messageDao saveWithContent:[self JSONStringFromObject:@{@"id": object.remoteID}]
                                   objectName:NSStringFromClass(object.class)
                                     objectId:object.remoteID
                                         type:@"delete"
                                         from:currentUser.userId
                                           to:@"*"
                                     sequence:[self generateNewSequence]
                                         node:group.defaults.node];
    // At last, we send the delete message to multiple untrusted servers.
    [self sendShares];
}

- (void)confirm {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSMutableArray *sequences = [[NSMutableArray alloc] init];
    // Find normal messages sent by current user.
    for (Message *normal in [dao.messageDao findNormalWithSender:currentUser.userId]) {
        [sequences addObject:normal.sequence];
    }
    if (sequences.count == 0) {
        return;
    }
    // Create control message by sendtimes.
    message = [dao.messageDao saveWithContent:[self JSONStringFromObject:@{
                                                @"node": group.defaults.node,
                                                @"sequences": sequences
                                            }]
                                   objectName:nil
                                     objectId:nil
                                         type:@"confirm"
                                         from:currentUser.userId
                                           to:@"*"
                                     sequence:[self generateNewSequence]
                                         node:group.defaults.node];
    [self sendShares];
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
        if (self.sent == net.managers.count) {
            [self removeObserver:self forKeyPath:@"sent"];
            if (DEBUG) {
                NSLog(@"%ld shares sent successfully in %@", (unsigned long)net.managers.count, [NSDate date]);
            }
            // Push remote notification to receiver if this message is a normal message.
            if ([message.type isEqualToString:@"update"]) {
                [self pushRemoteNotification:[NSString stringWithFormat:@"%@ has created or updated a %@.", currentUser.name, message.object]
                                          to:@"*"];
            } else if ([message.type isEqualToString:@"delete"]) {
                [self pushRemoteNotification:[NSString stringWithFormat:@"%@ has delete a %@.", currentUser.name, message.object]
                                          to:@"*"];

            }
        }
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

- (void)sendShares {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // Creat json string
    NSString *json = [self JSONStringFromObject:[message hyp_dictionary]];
    if (DEBUG) {
        NSLog(@"Send message: %@", json);
    }
    // Create several shares by secret sharing scheme.
    NSDictionary *shares = [SecretSharing generateSharesWith:json];
    // User KVO to observe the status of sending shares.
    self.sent = 0;
    [self addObserver:self
           forKeyPath:@"sent"
              options:NSKeyValueObservingOptionOld
              context:nil];
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

- (void)pushRemoteNotification:(NSString *)content to:(NSString *)reveiver {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSString *address0 = [net.managers.allKeys objectAtIndex:0];
    [net.managers[address0] POST:[NetManager createUrl:@"user/notify" withServerAddress:address0]
                  parameters:@{
                               @"content": content,
                               @"receiver": reveiver
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

@end
