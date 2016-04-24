//
//  SyncManager.h
//  GroupFinance
//
//  Created by lidaye on 4/23/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Ensembles/Ensembles.h>

@interface SyncManager : NSObject

@property (nonatomic, readonly, strong) CDEPersistentStoreEnsemble *ensemble;
@property (nonatomic, readwrite, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readwrite, copy) NSString *storePath;

+ (instancetype)shareSyncManager;



@end
