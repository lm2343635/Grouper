//
//  Message+CoreDataProperties.m
//  GroupFinance
//
//  Created by lidaye on 06/04/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "Message+CoreDataProperties.h"

@implementation Message (CoreDataProperties)

+ (NSFetchRequest<Message *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Message"];
}

@dynamic content;
@dynamic messageId;
@dynamic object;
@dynamic objectId;
@dynamic receiver;
@dynamic sender;
@dynamic sendtime;
@dynamic type;
@dynamic node;
@dynamic sequence;

@end
