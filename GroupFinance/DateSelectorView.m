//
//  DateSelectorView.m
//  AccountManagement
//
//  Created by 李大爷 on 15/5/11.
//  Copyright (c) 2015年 李大爷. All rights reserved.
//

#import "DateSelectorView.h"

@implementation DateSelectorView {
    UIViewController *parentController;
    UIDatePicker *datePicker;
    UIToolbar *toolBar;

    Callback doneButtonDidClicked;
}

- (instancetype)initForController:(UIViewController *)controller done:(Callback)callback {
    self = [super init];
    if (self) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        self.frame = CGRectMake(0, screenHeight, screenWidth, SeletorHeight + ToolBarHeight);
        
        toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, ToolBarHeight)];
        UIBarButtonItem *flexSpaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                             target:self
                                                                                             action:nil];
        UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                       target:self
                                                                       action:@selector(done)];
        [toolBar setItems:[NSArray arrayWithObjects:flexSpaceButtonItem, doneButtonItem, nil]];
        [self addSubview:toolBar];
        
        datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, ToolBarHeight, screenWidth, SeletorHeight)];
        datePicker.backgroundColor = [UIColor whiteColor];
        [self addSubview:datePicker];
        
        doneButtonDidClicked = callback;
        parentController = controller;
        [parentController.view addSubview:self];
    }
    return self;
}

// Show selecor
- (void)show {
    [UIView animateWithDuration:AnimationDurationTime animations:^{
        self.center = CGPointMake(self.center.x, self.center.y - SeletorHeight);
    }];
}

// Finish editing, close date selector view.
- (void)done {
    [UIView animateWithDuration:AnimationDurationTime animations:^{
        self.center = CGPointMake(self.center.x, self.center.y + SeletorHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        doneButtonDidClicked(datePicker.date);
    }];
}

@end
