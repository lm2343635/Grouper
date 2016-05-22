//
//  AlertTool.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AlertTool.h"

@implementation AlertTool

+(void)showAlert:(NSString *)message {
    if(DEBUG==1)
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Tip"
                                                  message:message
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
    [alert show];
}

@end
