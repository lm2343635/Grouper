//
//  Template.h
//  GroupFinance
//
//  Created by lidaye on 6/5/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account, AccountBook, Classification, Shop;

NS_ASSUME_NONNULL_BEGIN

@interface Template : NSManagedObject

- (BOOL)isEditableForUser:(NSString *)userId;

@end

NS_ASSUME_NONNULL_END

#import "Template+CoreDataProperties.h"
