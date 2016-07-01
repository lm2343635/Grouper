//
//  Shop+CoreDataProperties.h
//  GroupFinance
//
//  Created by lidaye on 7/1/16.
//  Copyright © 2016 limeng. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Shop.h"

NS_ASSUME_NONNULL_BEGIN

@interface Shop (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *sin;
@property (nullable, nonatomic, retain) NSString *sname;
@property (nullable, nonatomic, retain) NSNumber *sout;
@property (nullable, nonatomic, retain) NSString *uniqueIdentifier;
@property (nullable, nonatomic, retain) AccountBook *accountBook;

@end

NS_ASSUME_NONNULL_END
