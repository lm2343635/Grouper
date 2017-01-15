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
#import "Sender+CoreDataClass.h"
#import "User+CoreDataClass.h"
#import "Receiver+CoreDataClass.h"

@interface DaoTemplate : NSObject

@property (nonatomic,readonly) NSManagedObjectContext *context;

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)context;

- (void)saveContext;

//通过谓词和实体名称查询一个托管对象
- (NSManagedObject *)getByPredicate:(NSPredicate *)predicate
                    withEntityName:(NSString *)entityName;

//通过谓词、排序规则和实体名称查询一个托管对象
- (NSManagedObject *)getByPredicate:(NSPredicate *)predicate
                    withEntityName:(NSString *)entityName
                           orderBy:(NSSortDescriptor *)sortDescriptor;

//查询所有托管对象
- (NSArray *)findAllWithEntityName:(NSString *)entityName;

//通过谓词和实体名称查询一个托管对象数组
- (NSArray *)findByPredicate:(NSPredicate *)predicate
             withEntityName:(NSString *)entityName;

//通过谓词、排序规则和实体名称查询一个托管对象数组
- (NSArray *)findByPredicate:(NSPredicate *)predicate
             withEntityName:(NSString *)entityName
                    orderBy:(NSSortDescriptor *)sortDescriptor;

@end
