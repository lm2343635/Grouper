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
		self.sendtime = [dictionary[kMessageSendtime] integerValue];
	}

	if (![dictionary[kMessageSequence] isKindOfClass:[NSNull class]]){
		self.sequence = [dictionary[kMessageSequence] integerValue];
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
	dictionary[kMessageSequence] = @(self.sequence);
	if (self.type != nil){
		dictionary[kMessageType] = self.type;
	}
	return dictionary;

}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	if (self.content != nil){
		[aCoder encodeObject:self.content forKey:kMessageContent];
	}
	if (self.messageId != nil){
		[aCoder encodeObject:self.messageId forKey:kMessageMessageId];
	}
	if (self.object != nil){
		[aCoder encodeObject:self.object forKey:kMessageObject];
	}
	if (self.receiver != nil){
		[aCoder encodeObject:self.receiver forKey:kMessageReceiver];
	}
	[aCoder encodeObject:@(self.sendtime) forKey:kMessageSendtime];	[aCoder encodeObject:@(self.sequence) forKey:kMessageSequence];	if(self.type != nil){
		[aCoder encodeObject:self.type forKey:kMessageType];
	}

}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	self.content = [aDecoder decodeObjectForKey:kMessageContent];
	self.messageId = [aDecoder decodeObjectForKey:kMessageMessageId];
	self.object = [aDecoder decodeObjectForKey:kMessageObject];
	self.receiver = [aDecoder decodeObjectForKey:kMessageReceiver];
	self.sendtime = [[aDecoder decodeObjectForKey:kMessageSendtime] integerValue];
	self.sequence = [[aDecoder decodeObjectForKey:kMessageSequence] integerValue];
	self.type = [aDecoder decodeObjectForKey:kMessageType];
	return self;

}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
	Message *copy = [Message new];

	copy.content = [self.content copy];
	copy.messageId = [self.messageId copy];
	copy.object = [self.object copy];
	copy.receiver = [self.receiver copy];
	copy.sendtime = self.sendtime;
	copy.sequence = self.sequence;
	copy.type = [self.type copy];

	return copy;
}
@end
