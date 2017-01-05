//
//  Classification+CoreDataProperties.h
//  GroupFinance
//
//  Created by lidaye on 05/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "Classification+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Classification (CoreDataProperties)

+ (NSFetchRequest<Classification *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *cin;
@property (nullable, nonatomic, copy) NSString *cname;
@property (nullable, nonatomic, copy) NSNumber *cout;
@property (nullable, nonatomic, copy) NSString *creator;
@property (nullable, nonatomic, copy) NSString *remoteID;

@end

NS_ASSUME_NONNULL_END
