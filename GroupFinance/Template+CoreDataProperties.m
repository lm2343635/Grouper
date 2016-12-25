//
//  Template+CoreDataProperties.m
//  GroupFinance
//
//  Created by lidaye on 25/12/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "Template+CoreDataProperties.h"

@implementation Template (CoreDataProperties)

+ (NSFetchRequest<Template *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Template"];
}

@dynamic creator;
@dynamic saveRecordType;
@dynamic tname;
@dynamic account;
@dynamic classification;
@dynamic shop;

@end
