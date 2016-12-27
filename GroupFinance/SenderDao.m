//
//  SenderDao.m
//  GroupFinance
//
//  Created by 李大爷的电脑 on 01/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "SenderDao.h"
#import <SYNCPropertyMapper/SYNCPropertyMapper.h>

@implementation SenderDao

- (Sender *)saveWithObject:(NSManagedObject *)object {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Sender *sender = [NSEntityDescription insertNewObjectForEntityForName:SenderEntityName
                                                   inManagedObjectContext:self.context];
    sender.messageId = [[NSUUID UUID] UUIDString];
    sender.object = NSStringFromClass(object.class);
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:[object hyp_dictionary]
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    if (error) {
        NSLog(@"Create json with error: %@", error.localizedDescription);
        return nil;
    }
    sender.content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    sender.sendtime = [NSNumber numberWithInt:(int)[[NSDate date] timeIntervalSince1970]];
    sender.sequence = [NSNumber numberWithInt:1];
    sender.type = @"normal";
    sender.receiver = @"*";
    [self saveContext];
    return sender;
}

- (NSArray *)findResend {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"resend=%@", [NSNumber numberWithBool:YES]];
    return [self findByPredicate:predicate withEntityName:SenderEntityName];
}

@end
