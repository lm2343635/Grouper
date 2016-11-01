//
//  Sender+CoreDataProperties.m
//  GroupFinance
//
//  Created by 李大爷的电脑 on 01/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "Sender+CoreDataProperties.h"

@implementation Sender (CoreDataProperties)

+ (NSFetchRequest<Sender *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Sender"];
}

@dynamic sid;
@dynamic object;
@dynamic content;
@dynamic count;
@dynamic sendtime;
@dynamic resend;

@end
