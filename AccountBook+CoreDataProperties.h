//
//  AccountBook+CoreDataProperties.h
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "AccountBook.h"

NS_ASSUME_NONNULL_BEGIN

@interface AccountBook (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *abname;
@property (nullable, nonatomic, retain) NSString *uniqueIdentifier;
@property (nullable, nonatomic, retain) NSNumber *using;
@property (nullable, nonatomic, retain) NSSet<Classification *> *classifications;
@property (nullable, nonatomic, retain) NSSet<Shop *> *shops;
@property (nullable, nonatomic, retain) NSSet<Account *> *accounts;

@end

@interface AccountBook (CoreDataGeneratedAccessors)

- (void)addClassificationsObject:(Classification *)value;
- (void)removeClassificationsObject:(Classification *)value;
- (void)addClassifications:(NSSet<Classification *> *)values;
- (void)removeClassifications:(NSSet<Classification *> *)values;

- (void)addShopsObject:(Shop *)value;
- (void)removeShopsObject:(Shop *)value;
- (void)addShops:(NSSet<Shop *> *)values;
- (void)removeShops:(NSSet<Shop *> *)values;

- (void)addAccountsObject:(Account *)value;
- (void)removeAccountsObject:(Account *)value;
- (void)addAccounts:(NSSet<Account *> *)values;
- (void)removeAccounts:(NSSet<Account *> *)values;

@end

NS_ASSUME_NONNULL_END
