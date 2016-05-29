//
//  AppDelegate.m
//  GroupFinance
//
//  Created by lidaye on 4/23/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "SyncManager.h"

@interface AppDelegate ()

@property (nonatomic, readonly) NSURL *storeDirectoryURL;
@property (nonatomic, readonly) NSURL *storeURL;

@end

@implementation AppDelegate

@synthesize managedObjectContext = managedObjectContext;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    // Ensembles logging
    CDESetCurrentLoggingLevel(CDELoggingLevelVerbose);

    //Setup CoreData Stack
    [[NSFileManager defaultManager] createDirectoryAtURL:self.storeDirectoryURL
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:NULL];
    [self setupContext];
    
    //Setup Sync Manager
    SyncManager *syncManager=[SyncManager sharedSyncManager];
    syncManager.managedObjectContext=managedObjectContext;
    syncManager.storePath=self.storeURL.path;
    [syncManager setup];
    
    //Monitor saves
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                      object:managedObjectContext
                                                       queue:nil
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [syncManager synchronizeWithCompletion:nil];
                                                  }];
    
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UIBackgroundTaskIdentifier identifier=[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [managedObjectContext performBlock:^{
            if([managedObjectContext hasChanges]) {
                [managedObjectContext save:nil];
            }
            [[SyncManager sharedSyncManager] synchronizeWithCompletion:^(NSError *error) {
                [[UIApplication sharedApplication] endBackgroundTask:identifier];
            }];
        }];
    });
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [[SyncManager sharedSyncManager] synchronizeWithCompletion:nil];
}

#pragma mark - CoreDate Stack
- (void)setupContext {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSError *error;
    NSURL *modelURL=[[NSBundle mainBundle] URLForResource:@"Model"
                                            withExtension:@"momd"];
    NSManagedObjectModel *model=[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *coordinator=[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSDictionary *options=@{
                            NSMigratePersistentStoresAutomaticallyOption: @YES,
                            NSInferMappingModelAutomaticallyOption: @YES
                            };
    [coordinator addPersistentStoreWithType:NSSQLiteStoreType
                              configuration:nil
                                        URL:self.storeURL
                                    options:options
                                      error:&error];
    if(error) {
        NSLog(@"Error: %@", error.localizedDescription);
        return;
    }
    managedObjectContext=[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    managedObjectContext.persistentStoreCoordinator=coordinator;
    managedObjectContext.mergePolicy=NSMergeByPropertyObjectTrumpMergePolicy;
}

#pragma mark - Setters
- (NSURL *)storeDirectoryURL {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSURL *directoryURL=[[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory
                                                               inDomain:NSUserDomainMask
                                                      appropriateForURL:nil
                                                                 create:YES
                                                                  error:NULL];
    directoryURL=[directoryURL URLByAppendingPathComponent:NSBundle.mainBundle.bundleIdentifier isDirectory:YES];
    return directoryURL;
    
}

- (NSURL *)storeURL {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSURL *storeURL=[self.storeDirectoryURL URLByAppendingPathComponent:@"store.sqlite"];
    NSLog(@"Database file stores at %@", storeURL);
    return storeURL;
}

@end
