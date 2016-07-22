//
//  Account.h
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AccountBook;

NS_ASSUME_NONNULL_BEGIN

@interface Account : NSManagedObject

- (BOOL)isEditableForUser:(NSString *)userId;

@end

NS_ASSUME_NONNULL_END

#import "Account+CoreDataProperties.h"
