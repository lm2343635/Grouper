//
//  User+CoreDataProperties.m
//  Grouper
//
//  Created by lidaye on 30/05/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "User+CoreDataProperties.h"

@implementation User (CoreDataProperties)

+ (NSFetchRequest<User *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"User"];
}

@dynamic email;
@dynamic node;
@dynamic name;

@end
