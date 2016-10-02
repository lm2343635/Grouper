//
//  UserTool.h
//  GroupFinance
//
//  Created by lidaye on 02/10/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserTool : NSObject

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSData *picture;
@property (nonatomic, strong) NSString *pictureUrl;
@property (nonatomic, strong) NSString *userId;

@end
