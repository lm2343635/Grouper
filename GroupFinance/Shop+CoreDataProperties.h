//
//  Shop+CoreDataProperties.h
//  GroupFinance
//
//  Created by lidaye on 25/12/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "Shop+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Shop (CoreDataProperties)

+ (NSFetchRequest<Shop *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *creator;
@property (nullable, nonatomic, copy) NSNumber *sin;
@property (nullable, nonatomic, copy) NSString *sname;
@property (nullable, nonatomic, copy) NSNumber *sout;

@end

NS_ASSUME_NONNULL_END
