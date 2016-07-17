//
//  Account.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "Account.h"
#import "AccountBook.h"

@implementation Account

- (void)awakeFromInsert {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super awakeFromInsert];
    if(!self.creator) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.creator = [defaults valueForKey:@"userId"];
    }
}

@end
