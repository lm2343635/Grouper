//
//  DateSelectorView.h
//  AccountManagement
//
//  Created by 李大爷 on 15/5/11.
//  Copyright (c) 2015年 李大爷. All rights reserved.
//

#import <UIKit/UIKit.h>

// Animation duration time
#define AnimationDurationTime 0.3

// Select height and tool bar height
#define SeletorHeight 250
#define ToolBarHeight 30

// Define callback function type
typedef void (^Callback)(NSDate *);

@interface DateSelectorView : UIView

- (instancetype)initForController:(UIViewController *)controller done:(Callback)callback;

- (void)show;

@end
