//
//  CoreDaoTemplate.h
//  Grouper
//
//  Created by lidaye on 19/06/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User+CoreDataClass.h"
#import "Share+CoreDataClass.h"
#import "Message+CoreDataClass.h"
#import "SyncEntity+CoreDataClass.h"

@interface CoreDaoTemplate : NSObject

@property (nonatomic,readonly) NSManagedObjectContext *context;

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)context;

// Save changes to persistent store.
- (void)saveContext;

// Find a persistent object by prodicate and entity name.
- (NSManagedObject *)getByPredicate:(NSPredicate *)predicate
                     withEntityName:(NSString *)entityName;

// Find a persistent object by prodicate, sort descriptor and entity name.
- (NSManagedObject *)getByPredicate:(NSPredicate *)predicate
                     withEntityName:(NSString *)entityName
                            orderBy:(NSSortDescriptor *)sortDescriptor;

// Find all persistent objects by entity name.
- (NSArray *)findAllWithEntityName:(NSString *)entityName;

// Find persistent objects by prodicate and entity name.
- (NSArray *)findByPredicate:(NSPredicate *)predicate
              withEntityName:(NSString *)entityName;

// Find persistent objects by prodicate, sort descriptor and entity name.
- (NSArray *)findByPredicate:(NSPredicate *)predicate
              withEntityName:(NSString *)entityName
                     orderBy:(NSSortDescriptor *)sortDescriptor;


@end
