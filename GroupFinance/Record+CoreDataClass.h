//
//  Record+CoreDataClass.h
//  GroupFinance
//
//  Created by lidaye on 31/10/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account, Classification, Photo, Shop;

NS_ASSUME_NONNULL_BEGIN

@interface Record : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "Record+CoreDataProperties.h"
