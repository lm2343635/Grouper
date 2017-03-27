//
//	Message.h
//
//	Create by 萌 李 on 20/1/2017
//	Copyright © 2017. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageData : NSObject

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, strong) NSString *object;
@property (nonatomic, strong) NSString *receiver;
@property (nonatomic, assign) long long sendtime;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *sender;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary sender:(NSString *)sender;

- (NSDictionary *)toDictionary;

@end
