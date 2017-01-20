//
//  Shop+CoreDataProperties.m
//  GroupFinance
//
//  Created by lidaye on 20/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "Shop+CoreDataProperties.h"

@implementation Shop (CoreDataProperties)

+ (NSFetchRequest<Shop *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Shop"];
}

@dynamic sname;

@end
