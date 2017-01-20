//
//  SyncEntity+CoreDataClass.m
//  GroupFinance
//
//  Created by lidaye on 20/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "SyncEntity+CoreDataClass.h"

@implementation SyncEntity

- (void)awakeFromInsert {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super awakeFromInsert];
    if(!self.remoteID) {
        self.remoteID = [[NSUUID UUID] UUIDString];
        self.createAt = [NSDate date];
        self.updateAt = [NSDate date];
    }
}

@end
