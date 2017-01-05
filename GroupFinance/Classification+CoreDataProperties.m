//
//  Classification+CoreDataProperties.m
//  GroupFinance
//
//  Created by lidaye on 05/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
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
@dynamic remoteID;

@end
