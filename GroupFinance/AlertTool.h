//
//  AlertTool.h
//  MuShare-iOS
//
//  Created by 李大爷的电脑 on 7/12/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AlertTool : NSObject

+ (void)showAlertWithTitle:(NSString *)title
                andContent:(NSString *)content
          inViewController:(UIViewController *)controller;

@end
