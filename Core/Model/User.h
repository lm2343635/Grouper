//
//  User.h
//  Pods
//
//  Created by lidaye on 23/06/2017.
//
//

#import <CoreData/CoreData.h>

@interface User : NSManagedObject

@property (nullable, nonatomic, copy) NSString *email;
@property (nullable, nonatomic, copy) NSString *node;
@property (nullable, nonatomic, copy) NSString *name;

@end
