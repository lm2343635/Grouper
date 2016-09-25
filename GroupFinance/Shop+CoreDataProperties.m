//
//  Shop+CoreDataProperties.m
//  GroupFinance
//
//  Created by lidaye on 31/10/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "Shop+CoreDataProperties.h"

@implementation Shop (CoreDataProperties)

+ (NSFetchRequest<Shop *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Shop"];
}

@dynamic creator;
@dynamic sin;
@dynamic sname;
@dynamic sout;

@end
