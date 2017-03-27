//
//  Share+CoreDataProperties.m
//  GroupFinance
//
//  Created by lidaye on 27/03/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "Share+CoreDataProperties.h"

@implementation Share (CoreDataProperties)

+ (NSFetchRequest<Share *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Share"];
}

@dynamic shareId;

@end
