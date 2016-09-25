//
//  Photo+CoreDataProperties.m
//  GroupFinance
//
//  Created by lidaye on 31/10/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "Photo+CoreDataProperties.h"

@implementation Photo (CoreDataProperties)

+ (NSFetchRequest<Photo *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Photo"];
}

@dynamic createDate;
@dynamic data;
@dynamic userId;

@end
