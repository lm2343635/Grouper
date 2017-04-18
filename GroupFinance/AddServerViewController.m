//
//  AddServerViewController.m
//  GroupFinance
//
//  Created by lidaye on 19/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AddServerViewController.h"
#import "GroupManager.h"
#import "AlertTool.h"

@interface AddServerViewController ()

@end

@implementation AddServerViewController {
    GroupManager *group;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];

    group = [GroupManager sharedInstance];
    
    //If group id and group name has been set, autofill them and disable editing.
    if (group.defaults.groupId != nil && group.defaults.groupName != nil) {
        _groupIdTextField.text = group.defaults.groupId;
        _groupNameTextField.text = group.defaults.groupName;
        _groupIdTextField.enabled = NO;
        _groupNameTextField.enabled = NO;
    }
}

- (IBAction)submit:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    __weak typeof(self) weakSelf = self;
    [group addNewServer:_serverAddressTextField.text
          withGroupName:_groupNameTextField.text
             andGroupId:_groupIdTextField.text
             completion:^(BOOL success, NSString *message) {
                 if (success) {
                     [weakSelf.navigationController popViewControllerAnimated:YES];
                 } else {
                     [AlertTool showAlertWithTitle:@"Tip"
                                        andContent:message
                                  inViewController:weakSelf];
                 }
             }];
}

@end
