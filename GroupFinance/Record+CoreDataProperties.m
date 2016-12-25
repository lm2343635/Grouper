//
//  Record+CoreDataProperties.m
//  GroupFinance
//
//  Created by lidaye on 25/12/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "Record+CoreDataProperties.h"

@implementation Record (CoreDataProperties)

+ (NSFetchRequest<Record *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Record"];
}

@dynamic creator;
@dynamic money;
@dynamic remark;
@dynamic time;
@dynamic account;
@dynamic classification;
@dynamic photo;
@dynamic shop;

@end
