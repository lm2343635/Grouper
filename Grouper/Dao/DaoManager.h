//
//  DaoManager.h
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClassificationDao.h"
#import "AccountDao.h"
#import "ShopDao.h"
#import "RecordDao.h"
#import "PhotoDao.h"
#import "TemplateDao.h"
#import "AppDelegate.h"

@interface DaoManager : NSObject

@property (nonatomic, readonly) DataStack *dataStack;
@property (nonatomic, readonly) NSManagedObjectContext *context;

@property (strong, nonatomic) AccountDao *accountDao;
@property (strong, nonatomic) ClassificationDao *classificationDao;
@property (strong, nonatomic) ShopDao *shopDao;
@property (strong, nonatomic) RecordDao *recordDao;
@property (strong, nonatomic) PhotoDao *photoDao;
@property (strong, nonatomic) TemplateDao *templateDao;

//Get single instance of DaoManager
+ (instancetype)sharedInstance;

//Get object by object ID
- (NSManagedObject *)getObjectById:(NSManagedObjectID *)objectID;

//Save Core Data context
- (void)saveContext;

//Get data stack from dao manager
- (DataStack *)getDataStack;

@end
