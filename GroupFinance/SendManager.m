//
//  SendTool.m
//  GroupFinance
//
//  Created by lidaye on 04/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "SendManager.h"
#import "SecretSharing.h"
#import "InternetTool.h"
#import "GroupTool.h"
#import <SYNCPropertyMapper/SYNCPropertyMapper.h>

@implementation SendManager {
    NSDictionary *managers;
    DaoManager *dao;
    GroupTool *group;
    User *currentUser;
    
    // Sender object
    Sender *sender;
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
        dao = [DaoManager sharedInstance];
        managers = [InternetTool getSessionManagers];
        group = [GroupTool sharedInstance];
        currentUser = [dao.userDao currentUser];
    }
    return self;
}

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
    sender = [dao.senderDao saveWithContent:[self JSONStringFromObject:dictionary]
                                      object: NSStringFromClass(object.class)
                                        type:@"update"
                                 forReceiver:@"*"];
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
    sender = [dao.senderDao saveWithContent:[self JSONStringFromObject:@{@"id": object.remoteID}]
                                      object: NSStringFromClass(object.class)
                                        type:@"delete"
                                 forReceiver:@"*"];
    // At last, we send the delete message to multiple untrusted servers.
    [self sendShares];
}

- (void)confirm {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSMutableArray *sendtimes = [[NSMutableArray alloc] init];
    // Find all normal messages.
    for (Sender *normal in [dao.senderDao findNormal]) {
        [sendtimes addObject:normal.sendtime];
    }
    // Create control message by sendtimes.
    sender = [dao.senderDao saveWithContent:[self JSONStringFromObject:@{@"sendtimes": sendtimes}]
                                     object: nil
                                       type:@"confirm"
                                forReceiver:@"*"];
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
        if (self.sent == managers.count) {
            [self removeObserver:self forKeyPath:@"sent"];
            if (DEBUG) {
                NSLog(@"%ld shares sent successfully in %@", (unsigned long)managers.count, [NSDate date]);
            }
            // Push remote notification to receiver if this message is a normal message.
            if ([sender.type isEqualToString:@"update"]) {
                [self pushRemoteNotification:[NSString stringWithFormat:@"%@ has created or updated a %@.", currentUser.name, sender.object]
                                          to:@"*"];
            } else if ([sender.type isEqualToString:@"delete"]) {
                [self pushRemoteNotification:[NSString stringWithFormat:@"%@ has delete a %@.", currentUser.name, sender.object]
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
    NSString *json = [self JSONStringFromObject:[sender hyp_dictionary]];
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
    for (NSString *address in managers.allKeys) {
        [managers[address] POST:[InternetTool createUrl:@"transfer/put" withServerAddress:address]
                     parameters:@{
                                  @"share": shares[address],
                                  @"receiver": @"",
                                  @"mid": sender.messageId
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
    NSString *address0 = [group.servers.allKeys objectAtIndex:0];
    [managers[address0] POST:[InternetTool createUrl:@"user/notify" withServerAddress:address0]
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
