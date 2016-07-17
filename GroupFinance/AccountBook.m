//
//  AccountBook.m
//  GroupFinance
//
//  Created by lidaye on 4/26/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AccountBook.h"

@implementation AccountBook

- (void)awakeFromInsert {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super awakeFromInsert];
    if(!self.userId) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.userId=[defaults valueForKey:@"userId"];
    }
    if(!self.uniqueIdentifier) {
        self.uniqueIdentifier = [[NSUUID UUID] UUIDString];
    }
    if(!self.cooperaters) {
        self.cooperaters = @"[]";
    }
}

- (NSMutableArray *)getCooperatersWithJSONArray {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [NSJSONSerialization JSONObjectWithData:[self.cooperaters dataUsingEncoding:NSUTF8StringEncoding]
                                           options:NSJSONReadingMutableContainers
                                             error:nil];
}

- (void)setCooperatersWithJSONArray:(NSArray *)cooperaters {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self.cooperaters = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:cooperaters
                                                                                      options:NSJSONWritingPrettyPrinted
                                                                                        error:nil]
                                             encoding:NSUTF8StringEncoding];
}

@end
