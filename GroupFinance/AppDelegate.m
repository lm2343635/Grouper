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

// The changes from the original sample app are inside #if USE_COUCHBASE blocks
#define USE_COUCHBASE 1

// This is the URL of the remote database to sync with. This value assumes there is a Couchbase
// Sync Gateway running on your development machine with a database named "recipes" that has guest
// access enabled. You'll need to customize this to point to where your actual server is deployed.
#define COUCHBASE_SYNC_URL @"http://group.softlab.cs.tsukuba.ac.jp:4984/group_finance"

#define DB_NAME @"store"

// Enable/disable WebSocket in pull replication:
#define kSyncGatewayWebSocketSupport NO

// Guest DB Name:
#define kGuestDBName @"guest"

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

@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;

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
        [managedObjectContext performBlock:^{
            if([managedObjectContext hasChanges]) {
                [managedObjectContext save:nil];
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
    
    CBLIncrementalStore *store = (CBLIncrementalStore*)[coordinator persistentStores][0];
    [store addObservingManagedObjectContext:managedObjectContext];
    
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
    
    [CBLIncrementalStore updateManagedObjectModel:managedObjectModel];

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
    CBLIncrementalStore *store = (CBLIncrementalStore*)[persistentStoreCoordinator addPersistentStoreWithType:[CBLIncrementalStore type]
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

    return persistentStoreCoordinator;
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

#pragma mark Application's documents directory

- (NSString *)applicationDocumentsDirectory {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
