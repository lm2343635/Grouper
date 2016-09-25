//
//  Template+CoreDataProperties.h
//  GroupFinance
//
//  Created by lidaye on 31/10/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "Template+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Template (CoreDataProperties)

+ (NSFetchRequest<Template *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *creator;
@property (nullable, nonatomic, copy) NSNumber *saveRecordType;
@property (nullable, nonatomic, copy) NSString *tname;
@property (nullable, nonatomic, retain) Account *account;
@property (nullable, nonatomic, retain) Classification *classification;
@property (nullable, nonatomic, retain) Shop *shop;

@end

NS_ASSUME_NONNULL_END
