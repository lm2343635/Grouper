//
//  DaoManager.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "DaoManager.h"
#import "AppDelegate.h"

@implementation DaoManager

-(id)init {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    self=[super init];
    if(self) {
        _context=[(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        _accountBookDao=[[AccountBookDao alloc] initWithManagedObjectContext:_context];
        _accountDao=[[AccountDao alloc] initWithManagedObjectContext:_context];
        _classificationDao=[[ClassificationDao alloc] initWithManagedObjectContext:_context];
        _shopDao=[[ShopDao alloc] initWithManagedObjectContext:_context];
        _recordDao=[[RecordDao alloc] initWithManagedObjectContext:_context];
        _photoDao=[[PhotoDao alloc] initWithManagedObjectContext:_context];
        _templateDao=[[TemplateDao alloc] initWithManagedObjectContext:_context];
    }
    return self;
}

-(NSManagedObject *)getObjectById:(NSManagedObjectID *)objectID {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    return [_context existingObjectWithID:objectID error:nil];
}

- (void)saveContext{
    if(DEBUG==1)
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    if ([_context hasChanges]) {
        NSError *error=nil;
        if([_context save:&error]) {
            if(DEBUG==1)
                NSLog(@"_context saved changes to persistent store.");
        }
        else
            NSLog(@"Failed to save _context : %@",error);
    }else{
        NSLog(@"Skipped _context save, there are no changes.");
    }
}

@end
