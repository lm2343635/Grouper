//
//  UIManager.h
//  Pods
//
//  Created by lidaye on 22/06/2017.
//
//

#import <Foundation/Foundation.h>

@interface UIManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) UIStoryboard *main;

@property (nonatomic, strong) UIStoryboard *groupInit;
@property (nonatomic, strong) UIStoryboard *members;

@end
