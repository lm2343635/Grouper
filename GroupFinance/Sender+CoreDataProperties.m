//
//  Sender+CoreDataProperties.m
//  GroupFinance
//
//  Created by lidaye on 30/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "Sender+CoreDataProperties.h"

@implementation Sender (CoreDataProperties)

+ (NSFetchRequest<Sender *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Sender"];
}

@dynamic content;
@dynamic messageId;
@dynamic object;
@dynamic receiver;
@dynamic sendtime;
@dynamic type;

@end
