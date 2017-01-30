//
//  Template+CoreDataProperties.h
//  GroupFinance
//
//  Created by lidaye on 30/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "Template+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Template (CoreDataProperties)

+ (NSFetchRequest<Template *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *saveRecordType;
@property (nullable, nonatomic, copy) NSString *tname;
@property (nullable, nonatomic, retain) Account *account;
@property (nullable, nonatomic, retain) Classification *classification;
@property (nullable, nonatomic, retain) Shop *shop;

@end

NS_ASSUME_NONNULL_END
