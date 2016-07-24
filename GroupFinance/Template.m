//
//  Template.m
//  GroupFinance
//
//  Created by lidaye on 6/5/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "Template.h"
#import "Account.h"
#import "AccountBook.h"
#import "Classification.h"
#import "Shop.h"

@implementation Template

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

- (BOOL)isEditableForUser:(NSString *)userId {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [self.accountBook.owner isEqualToString:userId] || [self.creator isEqualToString:userId];
}

@end
