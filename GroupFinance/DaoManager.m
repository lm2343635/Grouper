//
//  DaoManager.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "DaoManager.h"

@implementation DaoManager

+ (instancetype)sharedInstance {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    static DaoManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DaoManager alloc] init];
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
        _dataStack = delegate.dataStack;
        _context = _dataStack.mainContext;
        //Set context for sync object dao
        _accountDao = [[AccountDao alloc] initWithManagedObjectContext:_context];
        _classificationDao = [[ClassificationDao alloc] initWithManagedObjectContext:_context];
        _shopDao = [[ShopDao alloc] initWithManagedObjectContext:_context];
        _recordDao = [[RecordDao alloc] initWithManagedObjectContext:_context];
        _photoDao = [[PhotoDao alloc] initWithManagedObjectContext:_context];
        _templateDao = [[TemplateDao alloc] initWithManagedObjectContext:_context];
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

- (DATAStack *)getDataStack {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    return _dataStack;
}

@end
