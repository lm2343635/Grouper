//
//  AccountBook.h
//  GroupFinance
//
//  Created by lidaye on 4/26/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class Classification;
@class Account;
@class Shop;

@interface AccountBook : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+ (instancetype)saveWithName:(NSString *)abname
              inMangedObjectContext:(NSManagedObjectContext *)context;

+ (NSArray *)findAllinMangedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "AccountBook+CoreDataProperties.h"
