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
    return [self deleteAllWithEntityName:ShareEntityName];
}

@end
