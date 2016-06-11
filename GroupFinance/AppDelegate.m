//
//  AppDelegate.m
//  GroupFinance
//
//  Created by lidaye on 4/23/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AppDelegate.h"
#import "CBLIncrementalStore.h"
#import <CouchbaseLite/CouchbaseLite.h>

// The changes from the original sample app are inside #if USE_COUCHBASE blocks
#define USE_COUCHBASE 1

// This is the URL of the remote database to sync with. This value assumes there is a Couchbase
// Sync Gateway running on your development machine with a database named "recipes" that has guest
// access enabled. You'll need to customize this to point to where your actual server is deployed.
#define COUCHBASE_SYNC_URL @"http://127.0.0.1:4984/recipes"

#define DB_NAME @"store"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
  
    
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [managedObjectContext performBlock:^{
            if([managedObjectContext hasChanges]) {
                [managedObjectContext save:nil];
            }

        }];
    });
}
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
#if USE_COUCHBASE
    CBLIncrementalStore *store = (CBLIncrementalStore*)[coordinator persistentStores][0];
    [store addObservingManagedObjectContext:managedObjectContext];
#endif
    
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
#if USE_COUCHBASE
    [CBLIncrementalStore updateManagedObjectModel:managedObjectModel];
#endif
    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
#if USE_COUCHBASE
    NSURL *storeUrl = [NSURL URLWithString:DB_NAME];
    
    CBLIncrementalStore *store;
    if ([[CBLManager sharedInstance] existingDatabaseNamed:DB_NAME error:&error]) {
        store = (CBLIncrementalStore*)[persistentStoreCoordinator addPersistentStoreWithType:[CBLIncrementalStore type]
                                                                               configuration:nil
                                                                                         URL:storeUrl options:nil error:&error];
    }
    /*
    else {
        NSURL *defaultStoreURL = [[NSBundle mainBundle] URLForResource:DB_NAME withExtension:@"sqlite"];
        NSDictionary *options = @{
                                  NSMigratePersistentStoresAutomaticallyOption : @YES,
                                  NSInferMappingModelAutomaticallyOption : @YES
                                  };
        NSPersistentStore *importStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                                  configuration:nil
                                                                                            URL:defaultStoreURL
                                                                                        options:options
                                                                                          error:&error];
        
        store = (CBLIncrementalStore*)[persistentStoreCoordinator migratePersistentStore:importStore toURL:storeUrl
                                                                                 options:nil
                                                                                withType:[CBLIncrementalStore type]
                                                                                   error:&error];
    }
     */
#else
    NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: [NSString stringWithFotmat:@"%@.sqlite", DB_NAME]];
    /*
     Set up the store.
     For the sake of illustration, provide a pre-populated default store.
     */
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:storePath]) {
        NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:DB_NAME ofType:@"sqlite"];
        if (defaultStorePath) {
            [fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
        }
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
    
    NSPersistentStore *store = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error];
    
#endif
    if (!store) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible
         * The schema for the persistent store is incompatible with current managed object model
         Check the error message to determine what the actual problem was.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
#if USE_COUCHBASE
    NSURL *remoteDbURL = [NSURL URLWithString:COUCHBASE_SYNC_URL];
    [self startReplication:[store.database createPullReplication:remoteDbURL]];
    [self startReplication:[store.database createPushReplication:remoteDbURL]];
#endif
    
    return persistentStoreCoordinator;
}


#if USE_COUCHBASE
/**
 * Utility method to configure, start and observe a replication.
 */
- (void)startReplication:(CBLReplication *)repl {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    repl.continuous = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(replicationProgress:)
                                                 name:kCBLReplicationChangeNotification object:repl];
    [repl start];
}

static BOOL sReplicationAlertShowing;

/**
 Observer method called when the push or pull replication's progress or status changes.
 */
- (void)replicationProgress:(NSNotification *)notification {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    CBLReplication *repl = notification.object;
    NSError* error = repl.lastError;
    NSLog(@"%@ replication: status = %d, progress = %u / %u, err = %@",
          (repl.pull ? @"Pull" : @"Push"), repl.status, repl.changesCount, repl.completedChangesCount,
          error.localizedDescription);
    
    if (error && !sReplicationAlertShowing) {
        NSLog(@"Sync failed with an error: %@", error.localizedDescription);
        sReplicationAlertShowing = YES;
    }
}

#endif


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
