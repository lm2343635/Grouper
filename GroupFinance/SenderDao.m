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

- (Sender *)saveWithContent:(NSString *)content
                     object:(NSString *)objectName
                       type:(NSString *)type
                forReceiver:(NSString *)receiver {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Sender *sender = [NSEntityDescription insertNewObjectForEntityForName:SenderEntityName
                                                   inManagedObjectContext:self.context];
    sender.object = objectName;
    sender.content = content;
    sender.sendtime = [NSNumber numberWithInt:(int)([[NSDate date] timeIntervalSince1970])];
    sender.sequence = [NSNumber numberWithInt:1];
    sender.type = type;
    sender.receiver = receiver;
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
