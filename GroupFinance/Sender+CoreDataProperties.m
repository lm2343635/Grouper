//
//  Sender+CoreDataProperties.m
//  GroupFinance
//
//  Created by lidaye on 27/12/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "Sender+CoreDataProperties.h"

@implementation Sender (CoreDataProperties)

+ (NSFetchRequest<Sender *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Sender"];
}

@dynamic content;
@dynamic messageId;
@dynamic object;
@dynamic sendtime;
@dynamic sequence;
@dynamic type;
@dynamic receiver;

@end
