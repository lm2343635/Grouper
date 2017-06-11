//
//  UserDao.m
//  GroupFinance
//
//  Created by lidaye on 04/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "UserDao.h"

@implementation UserDao

// Save user info.
- (User *)saveWithEmail:(NSString *)email
                forName:(NSString *)name
                 inNode:(NSString *)node {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    User *user = [NSEntityDescription insertNewObjectForEntityForName:UserEntityName
                                               inManagedObjectContext:self.context];
    user.email = email;
    user.name = name;
    user.node = node;
    [self saveContext];
    return user;
}

// Update user's info.
- (User *)updateName:(NSString *)name
                node:(NSString *)node
             byEmail:(NSString *)email {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    User *user = [self getByEmail:email];
    if(user == nil) {
        user = [NSEntityDescription insertNewObjectForEntityForName:UserEntityName
                                             inManagedObjectContext:self.context];
    }
    user.name = name;
    user.node = node;
    [self saveContext];
    return user;
}

- (User *)getByEmail:(NSString *)email {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email=%@", email];
    return (User *)[self getByPredicate:predicate withEntityName:UserEntityName];
}

- (User *)getByNode:(NSString *)node {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"node=%@", node];
    return (User *)[self getByPredicate:predicate withEntityName:UserEntityName];
}

- (NSArray *)findMembersExceptOwner:(NSString *)email {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [self findByPredicate:[NSPredicate predicateWithFormat:@"email!=%@", email]
                  withEntityName:UserEntityName
                         orderBy:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]];
}

- (NSArray *)findAll {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [self findByPredicate:nil
                  withEntityName:UserEntityName
                         orderBy:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]];
}

@end
