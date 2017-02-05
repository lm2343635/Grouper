//
//  Record+CoreDataProperties.m
//  GroupFinance
//
//  Created by 李大爷的电脑 on 05/02/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "Record+CoreDataProperties.h"

@implementation Record (CoreDataProperties)

+ (NSFetchRequest<Record *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Record"];
}

@dynamic money;
@dynamic remark;
@dynamic time;
@dynamic account;
@dynamic classification;
@dynamic photo;
@dynamic shop;

@end
