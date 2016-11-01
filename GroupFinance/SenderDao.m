//
//  SenderDao.m
//  GroupFinance
//
//  Created by 李大爷的电脑 on 01/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "SenderDao.h"

@implementation SenderDao

- (Sender *)saveWithObject:(NSManagedObject *)object {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Sender *sender = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(object.class)
                                                   inManagedObjectContext:self.context];
    sender.sid = [[NSUUID UUID] UUIDString];
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
    sender.count = [NSNumber numberWithInt:0];
    sender.resend = [NSNumber numberWithBool:YES];
    [self saveContext];
    return nil;
}

@end
