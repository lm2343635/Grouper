//
//  SyncManager.m
//  GroupFinance
//
//  Created by lidaye on 4/23/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "SyncManager.h"
#import "MultipeerManager.h"
#import "CDEMultipeerCloudFileSystem.h"

NSString * const SyncActivityDidBeginNotification = @"SyncActivityDidBegin";
NSString * const SyncActivityDidEndNotification = @"SyncActivityDidEnd";

@interface SyncManager () <CDEPersistentStoreEnsembleDelegate>

@end

@implementation SyncManager {
    id<CDECloudFileSystem> cloudFileSystem;
    NSUInteger activeMergeCount;
    MultipeerManager *multipeerManager;
}

@synthesize ensemble = ensemble;
@synthesize storePath = storePath;
@synthesize managedObjectContext = managedObjectContext;


+ (instancetype)shareSyncManager {
    static id shareInstance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance=[[SyncManager alloc] init];
    });
    return shareInstance;
}

- (instancetype) init {
    self=[super init];
    return self;
}

#pragma mark - Setting up and resetting
- (void)setup {
    [self setupEnsemble];
}

- (void)reset {
    [multipeerManager stop];
    [multipeerManager.multipeerCloudFileSystem removeAllFiles];
    multipeerManager=nil;
    
    ensemble.delegate=nil;
    ensemble=nil;
}

#pragma mark - Connecting to a Backend Service
- (void)connectToSyncService:(NSString *)serviceId withCompletion:(CDECompletionBlock)completion {
    [self setupEnsemble];
    [self synchronizeWithCompletion:completion];
}

- (void)disconnectFromSyncServiceWithCompletion:(CDECodeBlock)completion {
    [ensemble deleechPersistentStoreWithCompletion:^(NSError *error) {
        [self reset];
        if (completion) {
            completion();
        }
    }];
}


#pragma mark - Persistent Store Ensemble
- (void) setupEnsemble {
    cloudFileSystem=[self makeCloudFileSystem];
    if(!cloudFileSystem) {
        return;
    }
    NSURL *storeURL=[NSURL fileURLWithPath:storePath];
    NSURL *modelURL=[[NSBundle mainBundle] URLForResource:@"Model"
                                            withExtension:@"momd"];
    ensemble=[[CDEPersistentStoreEnsemble alloc] initWithEnsembleIdentifier:@"MainStore"
                                                         persistentStoreURL:storeURL
                                                      managedObjectModelURL:modelURL
                                                            cloudFileSystem:cloudFileSystem];
    ensemble.delegate=self;
}

- (id<CDECloudFileSystem>)makeCloudFileSystem {
    id <CDECloudFileSystem> newSystem = nil;
    multipeerManager=[[MultipeerManager alloc] init];
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path=[paths.lastObject stringByAppendingString:@"Group/Multipeer"];
    CDEMultipeerCloudFileSystem *multipeerCloudFileSystem = [[CDEMultipeerCloudFileSystem alloc] initWithRootDirectory:path
                                                                                                   multipeerConnection:multipeerManager];
    multipeerManager.multipeerCloudFileSystem=multipeerCloudFileSystem;
    [multipeerManager start];
    newSystem=multipeerCloudFileSystem;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didImportFiles)
                                                 name:CDEMultipeerCloudFileSystemDidImportFilesNotification
                                               object:nil];
    return newSystem;
}

#pragma mark - SyncMethods
- (void)synchronizeWithCompletion:(CDECompletionBlock)completion {
    [self incrementMergeCount];
    if(!ensemble.isLeeched) {
        [ensemble leechPersistentStoreWithCompletion:^(NSError *error) {
            [self decrementMergeCount];
            if(error&&!ensemble.isLeeched) {
                NSLog(@"Could not leech to ensemble: %@", error);
                [self disconnectFromSyncServiceWithCompletion:^{
                    if(completion) {
                        completion(error);
                    }
                }];
            }
        }];
    } else {
        [ensemble mergeWithCompletion:^(NSError *error) {
            [self decrementMergeCount];
            [multipeerManager syncFileWithAllPeers];
            if(error) {
                NSLog(@"Error mergeing: %@", error);
            }
            if(completion) {
                completion(error);
            }
        }];
    }
}

- (void)decrementMergeCount {
    activeMergeCount--;
    if(activeMergeCount==0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncActivityDidEndNotification
                                                            object:nil];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

- (void)incrementMergeCount {
    activeMergeCount++;
    if(activeMergeCount==1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncActivityDidBeginNotification
                                                            object:nil];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

#pragma mark - Persistent Store Ensemble Delegate
- (void)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble didSaveMergeChangesWithNotification:(NSNotification *)notification {
    [managedObjectContext performBlock:^{
        [managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    }];
}

- (NSArray *)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble globalIdentifiersForManagedObjects:(NSArray *)objects {
    return [objects valueForKey:@"uniqueIdentifier"];
}

-(void)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble didDeleechWithError:(NSError *)error {
    NSLog(@"Store did deleech with error: %@", error);
    [self reset];
}


#pragma mark - CDEMultipeerCloudFileSystem
- (void)didImportFiles {
    [self synchronizeWithCompletion: nil];
}

@end
