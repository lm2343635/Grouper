//
//  Message+CoreDataProperties.h
//  Grouper
//
//  Created by lidaye on 11/06/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "Message+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Message (CoreDataProperties)

+ (NSFetchRequest<Message *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *content;
@property (nullable, nonatomic, copy) NSString *messageId;
@property (nullable, nonatomic, copy) NSString *email;
@property (nullable, nonatomic, copy) NSString *object;
@property (nullable, nonatomic, copy) NSString *objectId;
@property (nullable, nonatomic, copy) NSString *receiver;
@property (nullable, nonatomic, copy) NSString *sender;
@property (nullable, nonatomic, copy) NSNumber *sendtime;
@property (nullable, nonatomic, copy) NSNumber *sequence;
@property (nullable, nonatomic, copy) NSString *type;
@property (nullable, nonatomic, copy) NSString *name;

@end

NS_ASSUME_NONNULL_END
