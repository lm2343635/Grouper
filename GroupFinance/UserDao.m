//
//  UserDao.m
//  GroupFinance
//
//  Created by lidaye on 04/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "UserDao.h"

@implementation UserDao

// Save user info from facebook.
- (User *)saveFromFacebook:(id)object {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    User *user = [NSEntityDescription insertNewObjectForEntityForName:UserEntityName
                                               inManagedObjectContext:self.context];
    user.userId = [object valueForKey:@"id"];
    user.email = [object valueForKey:@"email"];
    user.name = [object valueForKey:@"name"];
    user.gender = [object valueForKey:@"gender"];
    user.pictureUrl = [[[object valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"];
    [self saveContext];
    return user;
}

// Save other user's info from ustrusted servers.
- (User *)saveOrUpdate:(NSObject *)object {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    User *user = [self getByUserId:[object valueForKey:@"userId"]];
    if(user == nil) {
        user = [NSEntityDescription insertNewObjectForEntityForName:UserEntityName
                                             inManagedObjectContext:self.context];
    }
    user.userId = [object valueForKey:@"userId"];
    user.email = [object valueForKey:@"email"];
    user.name = [object valueForKey:@"name"];
    user.gender = [object valueForKey:@"gender"];
    user.pictureUrl = [object valueForKey:@"picture"];
    [self saveContext];
    return user;
}

- (User *)getByUserId:(NSString *)userId {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"userId=%@", userId];
    return (User *)[self getByPredicate:predicate withEntityName:UserEntityName];
}

- (User *)currentUser {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [self getByUserId:[defaults valueForKey:@"userId"]];
}

- (NSArray *)findMembersExceptOwner:(NSString *)ownerId {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [self findByPredicate:[NSPredicate predicateWithFormat:@"userId!=%@", ownerId]
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
