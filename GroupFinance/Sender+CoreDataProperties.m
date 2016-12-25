//
//  Sender+CoreDataProperties.m
//  GroupFinance
//
//  Created by lidaye on 25/12/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "Sender+CoreDataProperties.h"

@implementation Sender (CoreDataProperties)

+ (NSFetchRequest<Sender *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Sender"];
}

@dynamic content;
@dynamic type;
@dynamic object;
@dynamic sequence;
@dynamic sendtime;
@dynamic messageId;
@dynamic receiver;

@end
