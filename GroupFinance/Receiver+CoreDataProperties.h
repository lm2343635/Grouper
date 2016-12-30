//
//  Receiver+CoreDataProperties.h
//  GroupFinance
//
//  Created by lidaye on 30/12/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "Receiver+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Receiver (CoreDataProperties)

+ (NSFetchRequest<Receiver *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *shareId;
@property (nullable, nonatomic, copy) NSNumber *receiveTime;

@end

NS_ASSUME_NONNULL_END
