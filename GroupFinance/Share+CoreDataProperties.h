//
//  Share+CoreDataProperties.h
//  GroupFinance
//
//  Created by lidaye on 27/03/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "Share+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Share (CoreDataProperties)

+ (NSFetchRequest<Share *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *shareId;

@end

NS_ASSUME_NONNULL_END
