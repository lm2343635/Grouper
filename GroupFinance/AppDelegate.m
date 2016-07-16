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
#import <FBSDKCoreKit/FBSDKCoreKit.h>

// This is the URL of the remote database to sync with. This value assumes there is a Couchbase
// Sync Gateway running on your development machine with a database named "recipes" that has guest
// access enabled. You'll need to customize this to point to where your actual server is deployed.
#define COUCHBASE_SYNC_URL @"http://group.softlab.cs.tsukuba.ac.jp:4984/group_finance"

#define DB_NAME @"sync"

// Enable/disable WebSocket in pull replication:
#define kSyncGatewayWebSocketSupport NO

// Storage Type: kCBLSQLiteStorage or kCBLForestDBStorage
#define kStorageType kCBLSQLiteStorage

// Enable or disable logging:
#define kLoggingEnabled NO

@interface AppDelegate ()

@property (nonatomic) CBLReplication *push;
@property (nonatomic) CBLReplication *pull;
@property (nonatomic) NSError *lastSyncError;

@end

@implementation AppDelegate

@synthesize syncManagedObjectContext;
@synthesize syncManagedObjectModel;
@synthesize syncPersistentStoreCoordinator;
@synthesize staticManagedObjectContext;
@synthesize staticManagedObjectModel;
@synthesize staticPersistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [syncManagedObjectContext performBlock:^{
            if([syncManagedObjectContext hasChanges]) {
                [syncManagedObjectContext save:nil];
            }
        }];

    });
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [FBSDKAppEvents activateApp];
}


#pragma mark - Sync Core Data stack
/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)syncManagedObjectContext {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (syncManagedObjectContext != nil) {
        return syncManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self syncPersistentStoreCoordinator];
    if (coordinator != nil) {
        syncManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [syncManagedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    CBLIncrementalStore *store = (CBLIncrementalStore*)[coordinator persistentStores][0];
    [store addObservingManagedObjectContext:syncManagedObjectContext];
    
    return syncManagedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)syncManagedObjectModel {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (syncManagedObjectModel != nil) {
        return syncManagedObjectModel;
    }
    syncManagedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    [CBLIncrementalStore updateManagedObjectModel:syncManagedObjectModel];

    return syncManagedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)syncPersistentStoreCoordinator {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (syncPersistentStoreCoordinator != nil) {
        return syncPersistentStoreCoordinator;
    }
    
    NSError *error;
    syncPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self syncManagedObjectModel]];
    CBLIncrementalStore *store = (CBLIncrementalStore*)[syncPersistentStoreCoordinator addPersistentStoreWithType:[CBLIncrementalStore type]
                                                                                                configuration:nil
                                                                                                          URL:[NSURL URLWithString:DB_NAME]
                                                                                                      options:nil
                                                                                                        error:&error];

    if (!store) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    NSString *token=[[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    [self startReplicationWithAuthenticator:[CBLAuthenticator facebookAuthenticatorWithToken:token]
                                 inDatabase:store.database];

    if(DEBUG) {
        NSLog(@"Sync with facebook token %@", token);
    }

    return syncPersistentStoreCoordinator;
}

- (void)startReplicationWithAuthenticator:(id <CBLAuthenticator>)authenticator inDatabase:(CBLDatabase *)database {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }

    if (!_pull) {
        NSURL *syncUrl = [NSURL URLWithString:COUCHBASE_SYNC_URL];
        _pull = [database createPullReplication:syncUrl];
        _pull.continuous  = YES;
        if (!kSyncGatewayWebSocketSupport)
            _pull.customProperties = @{@"websocket": @NO};
        
        _push = [database createPushReplication:syncUrl];
        _push.continuous = YES;
        
        // Observe replication progress changes, in both directions:
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector: @selector(replicationProgress:)
                                   name:kCBLReplicationChangeNotification object:_pull];
        [notificationCenter addObserver: self selector: @selector(replicationProgress:)
                                   name:kCBLReplicationChangeNotification object:_push];
    }
    
    _pull.authenticator = authenticator;
    _push.authenticator = authenticator;
    
    if (_push.running) {
        [_push stop];
    }
    [_push start];
    
    if (_pull.running) {
        [_pull stop];
    }
    [_pull start];

}

- (void)replicationProgress:(NSNotification *)notification {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (_pull.status == kCBLReplicationActive || _push.status == kCBLReplicationActive) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    } else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    CBLReplication *repl = notification.object;
    NSError* error = repl.lastError;
    NSLog(@"%@ replication: status = %d, progress = %u / %u, err = %@",
          (repl.pull ? @"Pull" : @"Push"), repl.status, repl.changesCount, repl.completedChangesCount,
          error.localizedDescription);
    
    if (error) {
        NSLog(@"Sync failed with an error: %@", error.localizedDescription);
    }
    
    

}

#pragma mark - Static Core Data Stack
- (NSManagedObjectContext *)staticManagedObjectContext {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if(staticManagedObjectContext != nil) {
        return staticManagedObjectContext;
    }
    staticManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    staticManagedObjectContext.persistentStoreCoordinator = [self staticPersistentStoreCoordinator];
    staticManagedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    return staticManagedObjectContext;
}

- (NSPersistentStoreCoordinator *)staticPersistentStoreCoordinator {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if(staticPersistentStoreCoordinator != nil) {
        return staticPersistentStoreCoordinator;
    }
    staticPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self staticManagedObjectModel]];
    NSDictionary *options = @{
                            NSMigratePersistentStoresAutomaticallyOption: @YES,
                            NSInferMappingModelAutomaticallyOption: @YES
                            };
    NSURL *directoryURL = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory
                                                               inDomain:NSUserDomainMask
                                                      appropriateForURL:nil
                                                                 create:YES
                                                                  error:NULL];
    directoryURL = [directoryURL URLByAppendingPathComponent:NSBundle.mainBundle.bundleIdentifier isDirectory:YES];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSURL* storeURL = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingString:@"/static.sqlite"] isDirectory:NO];
    NSError *error;
    [staticPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error];
    if(error) {
        NSLog(@"Error: %@", error.localizedDescription);
        return nil;
    }
    return staticPersistentStoreCoordinator;
}

- (NSManagedObjectModel *)staticManagedObjectModel {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if(staticManagedObjectModel != nil) {
        return  staticManagedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Static" withExtension:@"momd"];
    staticManagedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return staticManagedObjectModel;
}

@end
