//
//  Classification+CoreDataProperties.h
//  GroupFinance
//
//  Created by lidaye on 31/10/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "Classification+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Classification (CoreDataProperties)

+ (NSFetchRequest<Classification *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *cin;
@property (nullable, nonatomic, copy) NSString *cname;
@property (nullable, nonatomic, copy) NSNumber *cout;
@property (nullable, nonatomic, copy) NSString *creator;

@end

NS_ASSUME_NONNULL_END
