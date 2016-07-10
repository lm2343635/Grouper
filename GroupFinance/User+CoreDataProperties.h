//
//  User+CoreDataProperties.h
//  GroupFinance
//
//  Created by lidaye on 7/10/16.
//  Copyright © 2016 limeng. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *token;
@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain) NSSet<AccountBook *> *myAccountBooks;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addMyAccountBooksObject:(AccountBook *)value;
- (void)removeMyAccountBooksObject:(AccountBook *)value;
- (void)addMyAccountBooks:(NSSet<AccountBook *> *)values;
- (void)removeMyAccountBooks:(NSSet<AccountBook *> *)values;

@end

NS_ASSUME_NONNULL_END
