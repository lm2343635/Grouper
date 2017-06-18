//
//  SecretSharing.h
//  GroupFinance
//
//  Created by lidaye on 17/10/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecretSharing : NSObject

+ (NSDictionary *)generateSharesWith:(NSString *)string;

+ (NSString *)recoverShareWith:(NSArray *)shares;

@end
