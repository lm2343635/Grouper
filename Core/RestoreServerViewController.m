//
//  RestoreServerViewController.m
//  GroupFinance
//
//  Created by lidaye on 26/12/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "RestoreServerViewController.h"
#import "GroupManager.h"
#import "AlertTool.h"

@interface RestoreServerViewController ()

@end

@implementation RestoreServerViewController {
    GroupManager *group;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    group = [GroupManager sharedInstance];
}

#pragma mark - Action
- (IBAction)restore:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [group restoreExistedServer:_addressTextField.text
                    byAccessKey:_accessKeyTextField.text
                     completion:^(BOOL success, NSString *message) {
                         if (success) {
                             [self.navigationController popViewControllerAnimated:YES];
                         } else {
                             [AlertTool showAlertWithTitle:@"Tip"
                                                andContent:message
                                          inViewController:self];
                         }
                     }];
}
@end
