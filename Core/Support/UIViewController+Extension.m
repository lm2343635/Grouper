//
//  UIViewController+Extension.m
//  Grouper
//
//  Created by lidaye on 19/06/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "UIViewController+Extension.h"

@implementation UIViewController (Extension)

- (void)showTip:(NSString *)content {
    [self showAlertWithTitle:@"Tip" andContent:content];
}

- (void)showWarning:(NSString *)content {
    [self showAlertWithTitle:@"Warning" andContent:content];
}

- (void)showAlertWithTitle:(NSString *)title
                andContent:(NSString *)content {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:content
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
