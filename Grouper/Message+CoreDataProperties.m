//
//  Message+CoreDataProperties.m
//  Grouper
//
//  Created by lidaye on 11/06/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "Message+CoreDataProperties.h"

@implementation Message (CoreDataProperties)

+ (NSFetchRequest<Message *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Message"];
}

@dynamic content;
@dynamic messageId;
@dynamic email;
@dynamic object;
@dynamic objectId;
@dynamic receiver;
@dynamic sender;
@dynamic sendtime;
@dynamic sequence;
@dynamic type;
@dynamic name;

@end
