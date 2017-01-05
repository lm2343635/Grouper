//
//  Classification+CoreDataClass.m
//  GroupFinance
//
//  Created by lidaye on 31/10/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "Classification+CoreDataClass.h"

@implementation Classification

- (void)awakeFromInsert {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super awakeFromInsert];
    if(!self.remoteID) {
        self.remoteID = [[NSUUID UUID] UUIDString];
    }
}

@end
