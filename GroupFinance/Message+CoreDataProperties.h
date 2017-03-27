//
//  Message+CoreDataProperties.h
//  GroupFinance
//
//  Created by lidaye on 27/03/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "Message+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Message (CoreDataProperties)

+ (NSFetchRequest<Message *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *mid;
@property (nullable, nonatomic, copy) NSNumber *sendtime;

@end

NS_ASSUME_NONNULL_END
