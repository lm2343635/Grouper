//
//  DaoTemplate.h
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Classification+CoreDataClass.h"
#import "Shop+CoreDataClass.h"
#import "Account+CoreDataClass.h"
#import "Record+CoreDataClass.h"
#import "Photo+CoreDataClass.h"
#import "Template+CoreDataClass.h"
#import "User+CoreDataClass.h"
#import "Share+CoreDataClass.h"
#import "Message+CoreDataClass.h"

@interface DaoTemplate : NSObject

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
