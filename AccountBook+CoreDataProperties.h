//
//  AccountBook+CoreDataProperties.h
//  GroupFinance
//
//  Created by lidaye on 5/29/16.
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
@property (nullable, nonatomic, retain) NSSet<Account *> *accounts;
@property (nullable, nonatomic, retain) NSSet<Classification *> *classifications;
@property (nullable, nonatomic, retain) NSSet<Shop *> *shops;
@property (nullable, nonatomic, retain) NSSet<Photo *> *photos;
@property (nullable, nonatomic, retain) NSSet<Record *> *records;

@end

@interface AccountBook (CoreDataGeneratedAccessors)

- (void)addAccountsObject:(Account *)value;
- (void)removeAccountsObject:(Account *)value;
- (void)addAccounts:(NSSet<Account *> *)values;
- (void)removeAccounts:(NSSet<Account *> *)values;

- (void)addClassificationsObject:(Classification *)value;
- (void)removeClassificationsObject:(Classification *)value;
- (void)addClassifications:(NSSet<Classification *> *)values;
- (void)removeClassifications:(NSSet<Classification *> *)values;

- (void)addShopsObject:(Shop *)value;
- (void)removeShopsObject:(Shop *)value;
- (void)addShops:(NSSet<Shop *> *)values;
- (void)removeShops:(NSSet<Shop *> *)values;

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet<Photo *> *)values;
- (void)removePhotos:(NSSet<Photo *> *)values;

- (void)addRecordsObject:(Record *)value;
- (void)removeRecordsObject:(Record *)value;
- (void)addRecords:(NSSet<Record *> *)values;
- (void)removeRecords:(NSSet<Record *> *)values;

@end

NS_ASSUME_NONNULL_END
