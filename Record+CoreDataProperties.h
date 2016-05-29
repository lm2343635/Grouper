//
//  Record+CoreDataProperties.h
//  GroupFinance
//
//  Created by lidaye on 5/29/16.
//  Copyright © 2016 limeng. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Record.h"

NS_ASSUME_NONNULL_BEGIN

@interface Record (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *money;
@property (nullable, nonatomic, retain) NSString *remark;
@property (nullable, nonatomic, retain) NSDate *time;
@property (nullable, nonatomic, retain) NSString *uniqueIdentifier;
@property (nullable, nonatomic, retain) Account *account;
@property (nullable, nonatomic, retain) Shop *shop;
@property (nullable, nonatomic, retain) Classification *classification;
@property (nullable, nonatomic, retain) Photo *photo;
@property (nullable, nonatomic, retain) AccountBook *accountBook;

@end

NS_ASSUME_NONNULL_END
