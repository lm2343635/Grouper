//
//  Record.h
//  GroupFinance
//
//  Created by lidaye on 5/29/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account, AccountBook, Classification, Shop;

NS_ASSUME_NONNULL_BEGIN

@class Photo;

@interface Record : NSManagedObject

- (BOOL)isEditableForUser:(NSString *)userId;

@end

NS_ASSUME_NONNULL_END

#import "Record+CoreDataProperties.h"
