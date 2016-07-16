//
//  AlertTool.m
//  MuShare-iOS
//
//  Created by 李大爷的电脑 on 7/12/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AlertTool.h"

@implementation AlertTool

+ (void)showAlertWithTitle:(NSString *)title
                andContent:(NSString *)content
          inViewController:(UIViewController *)controller {
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:title
                                                                           message:content
                                                                    preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"OK"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];
    [alertController addAction:cancelAction];
    [controller presentViewController:alertController animated:YES completion:nil];
}

@end
