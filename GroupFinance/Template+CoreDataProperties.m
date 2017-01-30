//
//  Template+CoreDataProperties.m
//  GroupFinance
//
//  Created by lidaye on 30/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "Template+CoreDataProperties.h"

@implementation Template (CoreDataProperties)

+ (NSFetchRequest<Template *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Template"];
}

@dynamic saveRecordType;
@dynamic tname;
@dynamic account;
@dynamic classification;
@dynamic shop;

@end
