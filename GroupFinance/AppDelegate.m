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

@implementation AppDelegate {
    NSManagedObjectContext *managedObjectContext;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //Setup CoreData Stack
    [[NSFileManager defaultManager] createDirectoryAtURL:self.storeDirectoryURL
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:NULL];
    [self setupContext];
    
    //Setup Sync Manager

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - CoreDate Stack
- (void)setupContext {
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
    NSURL *directoryURL=[[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory
                                                               inDomain:NSUserDomainMask
                                                      appropriateForURL:nil
                                                                 create:YES
                                                                  error:NULL];
    directoryURL=[directoryURL URLByAppendingPathComponent:NSBundle.mainBundle.bundleIdentifier isDirectory:YES];
    return directoryURL;
    
}

- (NSURL *)storeURL {
    NSURL *storeURL=[self.storeDirectoryURL URLByAppendingPathComponent:@"store.sqlite"];
    return storeURL;
}

@end
