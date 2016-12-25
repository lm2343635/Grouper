//
//  SecretSharing.m
//  GroupFinance
//
//  Created by lidaye on 17/10/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "SecretSharing.h"
#import "GroupTool.h"
#include "GLibFacade.h"
#include "shamir.h"

@implementation SecretSharing

+ (NSDictionary *)generateSharesWith:(NSString *)string {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    GroupTool *group = [[GroupTool alloc] init];
    NSArray *addresses = group.servers.allKeys;
    
    const char *secret = [string cStringUsingEncoding:NSUTF8StringEncoding];
    char *shares = generate_share_strings(secret, addresses.count, 2);
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
@end
