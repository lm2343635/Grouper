//
//  SyncEntity+CoreDataProperties.m
//  GroupFinance
//
//  Created by lidaye on 20/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "SyncEntity+CoreDataProperties.h"

@implementation SyncEntity (CoreDataProperties)

+ (NSFetchRequest<SyncEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"SyncEntity"];
}

@dynamic createAt;
@dynamic creator;
@dynamic remoteID;
@dynamic update;
@dynamic updateAt;

@end
