//
//  AccountBook+CoreDataProperties.h
//  GroupFinance
//
//  Created by lidaye on 4/26/16.
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

@end

NS_ASSUME_NONNULL_END
