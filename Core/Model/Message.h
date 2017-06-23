//
//  Message.h
//  Pods
//
//  Created by lidaye on 23/06/2017.
//
//

#import <CoreData/CoreData.h>

@interface Message : NSManagedObject

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
