//
//  Classification+CoreDataProperties.h
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Classification.h"

NS_ASSUME_NONNULL_BEGIN

@interface Classification (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *cname;
@property (nullable, nonatomic, retain) NSNumber *cin;
@property (nullable, nonatomic, retain) NSNumber *cout;
@property (nullable, nonatomic, retain) NSString *uniqueIdentifier;
@property (nullable, nonatomic, retain) AccountBook *accountBook;

@end

NS_ASSUME_NONNULL_END
