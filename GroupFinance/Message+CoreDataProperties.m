//
//  Message+CoreDataProperties.m
//  GroupFinance
//
//  Created by lidaye on 01/04/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "Message+CoreDataProperties.h"

@implementation Message (CoreDataProperties)

+ (NSFetchRequest<Message *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Message"];
}

@dynamic messageId;
@dynamic sendtime;
@dynamic objectId;
@dynamic content;
@dynamic object;
@dynamic type;
@dynamic receiver;
@dynamic sender;

@end
