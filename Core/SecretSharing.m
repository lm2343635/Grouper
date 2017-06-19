//
//  SecretSharing.m
//  GroupFinance
//
//  Created by lidaye on 17/10/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "SecretSharing.h"
#import "GroupManager.h"
#include "GLibFacade.h"
#include "shamir.h"

@implementation SecretSharing

+ (NSDictionary *)generateSharesWith:(NSString *)string {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    GroupManager *group = [GroupManager sharedInstance];
    NSArray *addresses = group.defaults.servers.allKeys;
    
    const char *secret = [string cStringUsingEncoding:NSUTF8StringEncoding];
    char *shares = "";// generate_share_strings(secret, addresses.count, group.defaults.threshold);
    NSString *result = [NSString stringWithCString:shares encoding:NSUTF8StringEncoding];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[result componentsSeparatedByString:@"\n"]];
    [array removeLastObject];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < addresses.count; i++) {
        [dictionary setValue:[array objectAtIndex:i]
                      forKey:[addresses objectAtIndex:i]];
    }
    
    return dictionary;
}

+ (NSString *)recoverShareWith:(NSArray *)shares {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSMutableString *strings = [[NSMutableString alloc] init];
    for (NSString *share in shares) {
        [strings appendString:share];
        [strings appendString:@"\n"];
    }
    const char *secret = ""; //extract_secret_from_share_strings([strings cStringUsingEncoding:NSUTF8StringEncoding]);
    return [NSString stringWithCString:secret encoding:NSUTF8StringEncoding];
}

@end
