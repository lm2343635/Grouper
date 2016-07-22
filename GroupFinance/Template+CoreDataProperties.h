//
//  Template+CoreDataProperties.h
//  GroupFinance
//
//  Created by lidaye on 7/19/16.
//  Copyright © 2016 limeng. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Template.h"

NS_ASSUME_NONNULL_BEGIN

@interface Template (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *saveRecordType;
@property (nullable, nonatomic, retain) NSString *tname;
@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain) Account *account;
@property (nullable, nonatomic, retain) AccountBook *accountBook;
@property (nullable, nonatomic, retain) Classification *classification;
@property (nullable, nonatomic, retain) Shop *shop;

@end

NS_ASSUME_NONNULL_END
