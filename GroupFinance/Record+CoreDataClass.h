//
//  Record+CoreDataClass.h
//  GroupFinance
//
//  Created by 李大爷的电脑 on 05/02/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncEntity+CoreDataClass.h"

@class Account, Classification, Photo, Shop;

NS_ASSUME_NONNULL_BEGIN

@interface Record : SyncEntity

@end

NS_ASSUME_NONNULL_END

#import "Record+CoreDataProperties.h"
