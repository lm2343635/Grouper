//
//  AddServerViewController.m
//  GroupFinance
//
//  Created by lidaye on 19/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AddServerViewController.h"
#import "Grouper.h"
#import "UIViewController+Extension.h"

@interface AddServerViewController ()

@end

@implementation AddServerViewController {
    Grouper *grouper;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];

    grouper = [Grouper sharedInstance];
    
    // If group id and group name has been set, autofill them and disable editing.
    if (grouper.group.defaults.groupId != nil && grouper.group.defaults.groupName != nil) {
        _groupIdTextField.text = grouper.group.defaults.groupId;
        _groupNameTextField.text = grouper.group.defaults.groupName;
        _groupIdTextField.enabled = NO;
        _groupNameTextField.enabled = NO;
    }
}

- (IBAction)submit:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    __weak typeof(self) weakSelf = self;
    [grouper.group addNewServer:_serverAddressTextField.text
          withGroupName:_groupNameTextField.text
             andGroupId:_groupIdTextField.text
             completion:^(BOOL success, NSString *message) {
                 if (success) {
                     [weakSelf.navigationController popViewControllerAnimated:YES];
                 } else {
                     [weakSelf showTip:message];
                 }
             }];
}

@end
