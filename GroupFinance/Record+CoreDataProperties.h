//
//  Record+CoreDataProperties.h
//  GroupFinance
//
//  Created by 李大爷的电脑 on 05/02/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "Record+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Record (CoreDataProperties)

+ (NSFetchRequest<Record *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *money;
@property (nullable, nonatomic, copy) NSString *remark;
@property (nullable, nonatomic, copy) NSDate *time;
@property (nullable, nonatomic, retain) Account *account;
@property (nullable, nonatomic, retain) Classification *classification;
@property (nullable, nonatomic, retain) Photo *photo;
@property (nullable, nonatomic, retain) Shop *shop;

@end

NS_ASSUME_NONNULL_END
