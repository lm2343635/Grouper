//
//  Sender+CoreDataProperties.h
//  GroupFinance
//
//  Created by 李大爷的电脑 on 01/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "Sender+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Sender (CoreDataProperties)

+ (NSFetchRequest<Sender *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *sid;
@property (nullable, nonatomic, copy) NSString *object;
@property (nullable, nonatomic, copy) NSString *content;
@property (nullable, nonatomic, copy) NSNumber *count;
@property (nullable, nonatomic, copy) NSDate *sendtime;
@property (nullable, nonatomic, copy) NSNumber *resend;

@end

NS_ASSUME_NONNULL_END
