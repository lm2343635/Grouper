//
//  Classification.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "Classification.h"
#import "AccountBook.h"

@implementation Classification

- (void)awakeFromInsert {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super awakeFromInsert];
    if(!self.userId) {
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        self.userId=[defaults valueForKey:@"userId"];
    }
}

@end
