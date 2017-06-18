//
//  GrouperDaoManager.m
//  Grouper
//
//  Created by lidaye on 18/06/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "GrouperDaoManager.h"

@implementation GrouperDaoManager

+ (instancetype)sharedInstance {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    static GrouperDaoManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GrouperDaoManager alloc] init];
    });
    return instance;
}

- (id)init {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    self = [super init];
    if (self) {
        //Get NSManagedObjectContent form AppDelegate
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _dataStack = delegate.grouperDataStack;
        _context = _dataStack.mainContext;
        //Set context for sync object dao
        _userDao = [[UserDao alloc] initWithManagedObjectContext:_context];
        _shareDao = [[ShareDao alloc] initWithManagedObjectContext:_context];
        _messageDao = [[MessageDao alloc] initWithManagedObjectContext:_context];
    }
    return self;
}

- (NSManagedObject *)getObjectById:(NSManagedObjectID *)objectID {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    return [_context existingObjectWithID:objectID error:nil];
}

- (void)saveContext {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    if ([_context hasChanges]) {
        NSError *error = nil;
        if([_context save:&error]) {
            if(DEBUG)
                NSLog(@"_context saved changes to persistent store.");
        } else {
            NSLog(@"Failed to save _context : %@",error);
        }
    } else {
        NSLog(@"Skipped _context save, there are no changes.");
    }
}

- (DataStack *)getDataStack {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    return _dataStack;
}

@end
