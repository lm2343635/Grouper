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

- (id)init {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    self=[super init];
    if(self) {
        //Get NSManagedObjectContent form AppDelegate
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _syncContext = [delegate syncManagedObjectContext];
        _staticContext = [delegate staticManagedObjectContext];
        //Set context for sync object dao
        _accountBookDao=[[AccountBookDao alloc] initWithManagedObjectContext:_syncContext];
        _accountDao=[[AccountDao alloc] initWithManagedObjectContext:_syncContext];
        _classificationDao=[[ClassificationDao alloc] initWithManagedObjectContext:_syncContext];
        _shopDao=[[ShopDao alloc] initWithManagedObjectContext:_syncContext];
        _recordDao=[[RecordDao alloc] initWithManagedObjectContext:_syncContext];
        _photoDao=[[PhotoDao alloc] initWithManagedObjectContext:_syncContext];
        _templateDao=[[TemplateDao alloc] initWithManagedObjectContext:_syncContext];
        //Set context for static object dao
        _userDao=[[UserDao alloc] initWithManagedObjectContext:_staticContext];
    }
    return self;
}

- (NSManagedObject *)getObjectById:(NSManagedObjectID *)objectID {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    return [_syncContext existingObjectWithID:objectID error:nil];
}

- (void)saveContext {
    if(DEBUG)
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    if ([_syncContext hasChanges]) {
        NSError *error = nil;
        if([_syncContext save:&error]) {
            if(DEBUG)
                NSLog(@"_context saved changes to persistent store.");
        }
        else
            NSLog(@"Failed to save _context : %@",error);
    }else{
        NSLog(@"Skipped _context save, there are no changes.");
    }
}

- (void)saveStaticContext {
    if(DEBUG)
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    if ([_staticContext hasChanges]) {
        NSError *error = nil;
        if([_staticContext save:&error]) {
            if(DEBUG)
                NSLog(@"_context saved changes to persistent store.");
        }
        else
            NSLog(@"Failed to save _context : %@",error);
    }else{
        NSLog(@"Skipped _context save, there are no changes.");
    }
}

@end
