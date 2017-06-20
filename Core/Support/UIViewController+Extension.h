//
//  UIViewController+Extension.h
//  Grouper
//
//  Created by lidaye on 19/06/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController(Extension)

- (void)showTip:(NSString *)content;

- (void)showWarning:(NSString *)content;

- (void)showAlertWithTitle:(NSString *)title
                andContent:(NSString *)content;

@end
