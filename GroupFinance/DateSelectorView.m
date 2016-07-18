//
//  DateSelectorView.m
//  AccountManagement
//
//  Created by 李大爷 on 15/5/11.
//  Copyright (c) 2015年 李大爷. All rights reserved.
//

#import "DateSelectorView.h"
#import "AlertTool.h"

@implementation DateSelectorView {
    //选择器视图高度
    CGFloat seletorHeight;
    //当前选择器是否被使用，选择器被使用时不能被另外一个按钮调用，除非点击done关闭选择器
    BOOL isUsing;
    //定义回调函数
    Callback doneButtonDidClicked;
    UIButton *doneButton;
    UIDatePicker *datePicker;
}

- (void)initWithCallback:(Callback)callback inViewController:(UIViewController *)controller {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    if(isUsing) {
        if(DEBUG) {
            NSLog(@"Selector is using by other button.");
        }
        [AlertTool showAlertWithTitle:@"Tip"
                           andContent:SelectorBeUsingTip
                     inViewController:controller];
    } else {
        doneButtonDidClicked=callback;
        datePicker=(UIDatePicker *)[self viewWithTag:1];
        //时间选择器的默认时间设为现在
        datePicker.date=[[NSDate alloc] init];
        doneButton=(UIButton *)[self viewWithTag:2];
        doneButton.enabled=YES;
        [doneButton addTarget:self
                       action:@selector(doneButtonClicked)
             forControlEvents:UIControlEventTouchUpInside];
        seletorHeight=self.frame.size.height;
        [self showSelector];
    }
}

#pragma mark - Action
//显示选择器
-(void)showSelector {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    CGPoint center=self.center;
    if(DEBUG) {
        NSLog(@"Selector start from (%f,%f)",center.x,center.y);
    }
    [UIView animateWithDuration:AnimationDurationTime animations:^{
        self.center=CGPointMake(center.x, center.y-seletorHeight);
    }];
}

//隐藏选择器
-(void)hideSelector {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    CGPoint center=self.center;
    if(DEBUG) {
        NSLog(@"Selector start from (%f,%f)",center.x,center.y);
    }
    [UIView animateWithDuration:AnimationDurationTime animations:^{
        self.center=CGPointMake(center.x, center.y+seletorHeight);
    }];
}

-(void)doneButtonClicked {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    [self hideSelector];
    //doneButton设为不可用
    doneButton.enabled=NO;
    //当前按钮释放选择器
    isUsing=NO;
    if(doneButtonDidClicked) {
        doneButtonDidClicked(datePicker.date);
    }
}

@end
