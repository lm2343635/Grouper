//
//  Shop.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "Shop.h"
#import "AccountBook.h"

@implementation Shop

- (void)awakeFromInsert {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super awakeFromInsert];
    if(!self.uniqueIdentifier) {
        self.uniqueIdentifier=[[NSUUID UUID] UUIDString];
    }
}

@end
