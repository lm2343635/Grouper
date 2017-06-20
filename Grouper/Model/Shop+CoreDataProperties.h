//
//  Shop+CoreDataProperties.h
//  GroupFinance
//
//  Created by lidaye on 20/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "Shop+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Shop (CoreDataProperties)

+ (NSFetchRequest<Shop *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *sname;

@end

NS_ASSUME_NONNULL_END
