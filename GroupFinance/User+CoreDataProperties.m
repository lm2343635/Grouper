//
//  User+CoreDataProperties.m
//  GroupFinance
//
//  Created by lidaye on 01/04/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "User+CoreDataProperties.h"

@implementation User (CoreDataProperties)

+ (NSFetchRequest<User *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"User"];
}

@dynamic email;
@dynamic gender;
@dynamic name;
@dynamic picture;
@dynamic pictureUrl;
@dynamic userId;

@end
