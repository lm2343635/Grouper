//
//	Message.m
//
//	Create by Meng Li on 20/1/2017
//	Copyright © 2017. All rights reserved.

#import "MessageData.h"

NSString *const kMessageContent = @"content";
NSString *const kMessageMessageId = @"message_id";
NSString *const kMessageObject = @"object";
NSString *const kMessageObjectId = @"objectId";
NSString *const kMessageSender = @"sender";
NSString *const kMessageReceiver = @"receiver";
NSString *const kMessageSendtime = @"sendtime";
NSString *const kMessageSequence = @"sequence";
NSString *const kMessageType = @"type";
NSString *const kSequenceType = @"sequence";
NSString *const kEmailType = @"email";
NSString *const kNameType = @"name";

@interface MessageData ()

@end

@implementation MessageData

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
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
    if (![dictionary[kMessageObjectId] isKindOfClass:[NSNull class]]){
        self.objectId = dictionary[kMessageObjectId];
    }
    if (![dictionary[kMessageSender] isKindOfClass:[NSNull class]]){
        self.sender = dictionary[kMessageSender];
    }
	if (![dictionary[kMessageReceiver] isKindOfClass:[NSNull class]]){
		self.receiver = dictionary[kMessageReceiver];
	}	
	if (![dictionary[kMessageSendtime] isKindOfClass:[NSNull class]]){
		self.sendtime = [dictionary[kMessageSendtime] longValue];
	}
	if (![dictionary[kMessageType] isKindOfClass:[NSNull class]]){
		self.type = dictionary[kMessageType];
	}
    if (![dictionary[kSequenceType] isKindOfClass:[NSNull class]]) {
        self.sequence = [dictionary[kSequenceType] longValue];
    }
    if (![dictionary[kEmailType] isKindOfClass:[NSNull class]]) {
        self.email = dictionary[kEmailType];
    }
    if (![dictionary[kNameType] isKindOfClass:[NSNull class]]) {
        self.name = dictionary[kNameType];
    }
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
    if (self.objectId != nil){
        dictionary[kMessageObjectId] = self.objectId;
    }
    if (self.sender != nil){
        dictionary[kMessageSender] = self.sender;
    }
	if (self.receiver != nil){
		dictionary[kMessageReceiver] = self.receiver;
	}
	dictionary[kMessageSendtime] = @(self.sendtime);
	if (self.type != nil){
		dictionary[kMessageType] = self.type;
	}
    dictionary[kSequenceType] = @(self.sequence);
    if (self.email != nil) {
        dictionary[kEmailType] = self.email;
    }
    if (self.name != nil) {
        dictionary[kNameType] = self.name;
    }
	return dictionary;

}

@end
