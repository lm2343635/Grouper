//
//  GroupTool.h
//  GroupFinance
//
//  Created by lidaye on 19/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupTool : NSObject

typedef NS_OPTIONS(NSUInteger, InitialState) {
    NotInitial = 0,
    RestoringServer = 2,
    AddingNewServer = 3,
    InitialFinished = 4
};

//User id of owner
@property (nonatomic) NSString *owner;
@property (nonatomic) NSInteger members;

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSDictionary *servers;
@property (nonatomic) NSInteger serverCount;
@property (nonatomic) NSInteger threshold;

@property (nonatomic) NSInteger initial;

- (NSUInteger)addServerAddress:(NSString *)address withAccessKey:(NSString *)accessKey;

@end
