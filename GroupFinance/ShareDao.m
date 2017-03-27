//
//  ShareDao.m
//  GroupFinance
//
//  Created by lidaye on 27/03/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "ShareDao.h"

@implementation ShareDao

- (Share *)saveWithShareId:(NSString *)shareId {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Share *share = [NSEntityDescription insertNewObjectForEntityForName:ShareEntityName
                                                       inManagedObjectContext:self.context];
    share.shareId = shareId;
    [self saveContext];
    return share;
}

- (NSArray *)findInShareIds:(NSArray *)shareIds {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [self findByPredicate:[NSPredicate predicateWithFormat:@"shareId IN %@", shareIds]
                  withEntityName:ShareEntityName];
}

- (BOOL)deleteAll {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSFetchRequest *fetchrequest = [[NSFetchRequest alloc] initWithEntityName:ShareEntityName];
    NSBatchDeleteRequest *deleteRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:fetchrequest];
    NSError *error = nil;
    [self.context.persistentStoreCoordinator executeRequest:deleteRequest
                                                withContext:self.context
                                                      error:&error];
    if (error) {
        NSLog(@"Delete all %@ with error: %@", ShareEntityName, error.localizedDescription);
        return NO;
    }
    return YES;
}

@end
