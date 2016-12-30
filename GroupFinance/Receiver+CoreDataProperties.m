//
//  Receiver+CoreDataProperties.m
//  GroupFinance
//
//  Created by lidaye on 30/12/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "Receiver+CoreDataProperties.h"

@implementation Receiver (CoreDataProperties)

+ (NSFetchRequest<Receiver *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Receiver"];
}

@dynamic shareId;
@dynamic receiveTime;

@end
