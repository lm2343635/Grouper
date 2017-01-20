//
//	Message.h
//
//	Create by 萌 李 on 20/1/2017
//	Copyright © 2017. All rights reserved.
//

//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

#import <UIKit/UIKit.h>

@interface Message : NSObject

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *messageId;
@property (nonatomic, strong) NSString *object;
@property (nonatomic, strong) NSString *receiver;
@property (nonatomic, assign) NSInteger sendtime;
@property (nonatomic, assign) NSInteger sequence;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *sender;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary sender:(NSString *)sender;

- (NSDictionary *)toDictionary;

@end
