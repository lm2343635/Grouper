//
//  DaoManager.h
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountBookDao.h"
#import "ClassificationDao.h"
#import "AccountDao.h"
#import "ShopDao.h"
#import "RecordDao.h"
#import "PhotoDao.h"

@interface DaoManager : NSObject

@property (nonatomic,readonly) NSManagedObjectContext *context;

@property (strong,nonatomic) AccountBookDao *accountBookDao;
@property (strong,nonatomic) AccountDao *accountDao;
@property (strong,nonatomic) ClassificationDao *classificationDao;
@property (strong,nonatomic) ShopDao *shopDao;
@property (strong,nonatomic) RecordDao *recordDao;
@property (strong,nonatomic) PhotoDao *photoDao;

-(NSManagedObject *)getObjectById:(NSManagedObjectID *)objectID;

- (void)saveContext;

@end
