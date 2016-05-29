//
//  DateSelectorView.h
//  AccountManagement
//
//  Created by 李大爷 on 15/5/11.
//  Copyright (c) 2015年 李大爷. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DatePickerSelectorDebug 0
//选择器被其他按钮占用时，提示用户先完成当前按钮的选择
#define SelectorBeUsingTip @"Please finish what you are choosing now."
//动画时间长度
#define AnimationDurationTime 0.3

//定义回调函数数据类型
typedef void (^Callback)(NSObject *);

@interface DateSelectorView : UIView

-(void)initWithCallback:(Callback)callback;

@end
