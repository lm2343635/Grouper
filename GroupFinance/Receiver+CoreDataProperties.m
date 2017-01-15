//
//  Receiver+CoreDataProperties.m
//  GroupFinance
//
//  Created by lidaye on 15/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "Receiver+CoreDataProperties.h"

@implementation Receiver (CoreDataProperties)

+ (NSFetchRequest<Receiver *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Receiver"];
}

@dynamic receiveTime;
@dynamic shareId;

@end
