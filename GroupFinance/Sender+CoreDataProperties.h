//
//  Sender+CoreDataProperties.h
//  GroupFinance
//
//  Created by lidaye on 30/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "Sender+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Sender (CoreDataProperties)

+ (NSFetchRequest<Sender *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *content;
@property (nullable, nonatomic, copy) NSString *messageId;
@property (nullable, nonatomic, copy) NSString *object;
@property (nullable, nonatomic, copy) NSString *receiver;
@property (nullable, nonatomic, copy) NSNumber *sendtime;
@property (nullable, nonatomic, copy) NSString *type;

@end

NS_ASSUME_NONNULL_END
