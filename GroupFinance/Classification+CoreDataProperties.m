//
//  Classification+CoreDataProperties.m
//  GroupFinance
//
//  Created by lidaye on 25/12/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "Classification+CoreDataProperties.h"

@implementation Classification (CoreDataProperties)

+ (NSFetchRequest<Classification *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Classification"];
}

@dynamic cin;
@dynamic cname;
@dynamic cout;
@dynamic creator;

@end
