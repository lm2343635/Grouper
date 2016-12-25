//
//  Sender+CoreDataProperties.h
//  GroupFinance
//
//  Created by lidaye on 25/12/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "Sender+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Sender (CoreDataProperties)

+ (NSFetchRequest<Sender *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *content;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSString *object;
@property (nullable, nonatomic, copy) NSNumber *sequence;
@property (nullable, nonatomic, copy) NSNumber *sendtime;
@property (nullable, nonatomic, copy) NSString *messageId;
@property (nullable, nonatomic, retain) User *receiver;

@end

NS_ASSUME_NONNULL_END
