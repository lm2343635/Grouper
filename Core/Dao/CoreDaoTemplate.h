//
//  CoreDaoTemplate.h
//  Grouper
//
//  Created by lidaye on 19/06/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Share.h"
#import "Message.h"
#import "SyncEntity.h"
#import "DEBUG.h"

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

// Delete all entities
- (BOOL)deleteAllWithEntityName:(NSString *)entityName; 

@end
