//
//  SyncEntity+CoreDataProperties.h
//  GroupFinance
//
//  Created by lidaye on 20/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "SyncEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface SyncEntity (CoreDataProperties)

+ (NSFetchRequest<SyncEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *createAt;
@property (nullable, nonatomic, copy) NSString *creator;
@property (nullable, nonatomic, copy) NSString *remoteID;
@property (nullable, nonatomic, copy) NSString *updater;
@property (nullable, nonatomic, copy) NSDate *updateAt;

@end

NS_ASSUME_NONNULL_END
