//
//  User+CoreDataProperties.h
//  GroupFinance
//
//  Created by lidaye on 7/14/16.
//  Copyright © 2016 limeng. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain) NSString *gender;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *pictureUrl;
@property (nullable, nonatomic, retain) NSData *picture;
@property (nullable, nonatomic, retain) NSString *name;

@end

NS_ASSUME_NONNULL_END
