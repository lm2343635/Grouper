//
//  SecretSharing.m
//  GroupFinance
//
//  Created by lidaye on 17/10/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "SecretSharing.h"
#include "GLibFacade.h"
#include "shamir.h"

@implementation SecretSharing

+ (NSArray *)generateSharesWith:(NSString *)string
                          parts:(int)n
                        recover:(int)k {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    const char *secret = [string cStringUsingEncoding:NSUTF8StringEncoding];
    char *shares = generate_share_strings(secret, n, k);
    NSString *result = [NSString stringWithCString:shares encoding:NSUTF8StringEncoding];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[result componentsSeparatedByString:@"\n"]];
    [array removeLastObject];
    return array;
}
@end
