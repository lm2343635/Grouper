//
//  Account+CoreDataProperties.h
//  GroupFinance
//
//  Created by 李大爷的电脑 on 7/24/16.
//  Copyright © 2016 limeng. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Account.h"

NS_ASSUME_NONNULL_BEGIN

@interface Account (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *ain;
@property (nullable, nonatomic, retain) NSString *aname;
@property (nullable, nonatomic, retain) NSNumber *aout;
@property (nullable, nonatomic, retain) NSString *creator;
@property (nullable, nonatomic, retain) AccountBook *accountBook;

@end

NS_ASSUME_NONNULL_END
