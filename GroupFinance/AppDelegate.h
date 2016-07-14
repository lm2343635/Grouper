//
//  AppDelegate.h
//  GroupFinance
//
//  Created by lidaye on 4/23/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readonly) NSManagedObjectModel *syncManagedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *syncManagedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *syncPersistentStoreCoordinator;

@property (nonatomic, strong, readonly) NSManagedObjectModel *staticManagedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *staticManagedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *staticPersistentStoreCoordinator;

@end

