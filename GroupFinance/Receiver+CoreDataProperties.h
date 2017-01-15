//
//  Receiver+CoreDataProperties.h
//  GroupFinance
//
//  Created by lidaye on 15/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "Receiver+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Receiver (CoreDataProperties)

+ (NSFetchRequest<Receiver *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *receiveTime;
@property (nullable, nonatomic, copy) NSString *shareId;

@end

NS_ASSUME_NONNULL_END
