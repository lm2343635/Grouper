//
//  Account+CoreDataProperties.m
//  GroupFinance
//
//  Created by lidaye on 25/12/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "Account+CoreDataProperties.h"

@implementation Account (CoreDataProperties)

+ (NSFetchRequest<Account *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Account"];
}

@dynamic ain;
@dynamic aname;
@dynamic aout;
@dynamic creator;

@end
