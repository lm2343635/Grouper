//
//  UserDao.m
//  GroupFinance
//
//  Created by lidaye on 7/1/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "UserDao.h"

@implementation UserDao

- (NSManagedObjectID *)saveWithToken:(NSString *)token andUid:(NSString *)uid {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    User *user=[NSEntityDescription insertNewObjectForEntityForName:UserEntityName
                                             inManagedObjectContext:self.context];
    user.token=token;
    user.uid=uid;
    [self saveContext];
    return user.objectID;
}

- (User *)getByToken:(NSString *)token {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"token=%@", token];
    return (User *)[self getByPredicate:predicate withEntityName:UserEntityName];
}

- (User *)getUsingUser {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    return [self getByToken:[defaults valueForKey:@"token"]];
}

@end
