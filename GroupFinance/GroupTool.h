//
//  GroupTool.h
//  GroupFinance
//
//  Created by lidaye on 19/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupTool : NSObject

@property (nonatomic) BOOL owner;
@property (nonatomic) NSInteger members;

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSDictionary *servers;

@end
