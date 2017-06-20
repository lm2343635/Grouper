//
//  GrouperDaoManager.h
//  Grouper
//
//  Created by lidaye on 18/06/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserDao.h"
#import "ShareDao.h"
#import "MessageDao.h"
#import "Core-Bridging-Header.h"

@interface CoreDaoManager : NSObject

@property (strong, nonatomic) NSManagedObjectModel *model;
@property (strong, nonatomic) NSPersistentStoreCoordinator *coordinator;
@property (strong, nonatomic) NSManagedObjectContext *context;

@property (strong, nonatomic) UserDao *userDao;
@property (strong, nonatomic) ShareDao *shareDao;
@property (strong, nonatomic) MessageDao *messageDao;

//Get single instance of DaoManager
+ (instancetype)sharedInstance;

//Get object by object ID
- (NSManagedObject *)getObjectById:(NSManagedObjectID *)objectID;

//Save Core Data context
- (void)saveContext;

@end
