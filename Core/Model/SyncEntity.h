//
//  SyncEntity.h
//  Pods
//
//  Created by lidaye on 23/06/2017.
//
//

#import <CoreData/CoreData.h>

@interface SyncEntity : NSManagedObject

@property (nullable, nonatomic, copy) NSDate *createAt;
@property (nullable, nonatomic, copy) NSString *creator;
@property (nullable, nonatomic, copy) NSString *remoteID;
@property (nullable, nonatomic, copy) NSString *updator;
@property (nullable, nonatomic, copy) NSDate *updateAt;

@end
