//
//	Message.m
//
//	Create by 萌 李 on 20/1/2017
//	Copyright © 2017. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "Message.h"

NSString *const kMessageContent = @"content";
NSString *const kMessageMessageId = @"message_id";
NSString *const kMessageObject = @"object";
NSString *const kMessageReceiver = @"receiver";
NSString *const kMessageSendtime = @"sendtime";
NSString *const kMessageSequence = @"sequence";
NSString *const kMessageType = @"type";

@interface Message ()

@end

@implementation Message

- (instancetype)initWithDictionary:(NSDictionary *)dictionary sender:(NSString *)sender {
	self = [super init];
	if (![dictionary[kMessageContent] isKindOfClass:[NSNull class]]){
		self.content = dictionary[kMessageContent];
	}	
	if (![dictionary[kMessageMessageId] isKindOfClass:[NSNull class]]){
		self.messageId = dictionary[kMessageMessageId];
	}	
	if (![dictionary[kMessageObject] isKindOfClass:[NSNull class]]){
		self.object = dictionary[kMessageObject];
	}	
	if (![dictionary[kMessageReceiver] isKindOfClass:[NSNull class]]){
		self.receiver = dictionary[kMessageReceiver];
	}	
	if (![dictionary[kMessageSendtime] isKindOfClass:[NSNull class]]){
		self.sendtime = [dictionary[kMessageSendtime] longLongValue];
	}
	if (![dictionary[kMessageType] isKindOfClass:[NSNull class]]){
		self.type = dictionary[kMessageType];
	}
    self.sender = sender;
	return self;
}

- (NSDictionary *)toDictionary {
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	if (self.content != nil){
		dictionary[kMessageContent] = self.content;
	}
	if (self.messageId != nil){
		dictionary[kMessageMessageId] = self.messageId;
	}
	if (self.object != nil){
        dictionary[kMessageObject] = self.object;
	}
	if (self.receiver != nil){
		dictionary[kMessageReceiver] = self.receiver;
	}
	dictionary[kMessageSendtime] = @(self.sendtime);
	if (self.type != nil){
		dictionary[kMessageType] = self.type;
	}
	return dictionary;

}

@end
