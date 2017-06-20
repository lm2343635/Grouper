//
//  PhotoDao.m
//  GroupFinance
//
//  Created by lidaye on 5/29/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "PhotoDao.h"

@implementation PhotoDao

- (NSManagedObjectID *)saveWithData:(NSData *)pdata {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:PhotoEntityName
                                                 inManagedObjectContext:self.context];
    photo.data = pdata;
    photo.createDate = [NSDate date];
    [self saveContext];
    return photo.objectID;
}

@end
