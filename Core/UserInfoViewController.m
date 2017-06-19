//
//  LoginViewController.m
//  GroupFinance
//
//  Created by lidaye on 6/12/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "UserInfoViewController.h"
#import "DaoManager.h"
#import "GroupManager.h"
#import "UIViewController+Extension.h"

@interface UserInfoViewController ()

@end

@implementation UserInfoViewController {
    DaoManager *dao;
    NSUserDefaults *defaults;
    GroupManager *group;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    dao = [[DaoManager alloc] init];
    group = [GroupManager sharedInstance];
    if (group.currentUser != nil) {
        _nameTextField.text = group.currentUser.name;
        _emailTextField.text = group.currentUser.email;
    }
}

#pragma mark - Action

- (IBAction)setUserInfo:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([_emailTextField.text isEqualToString:@""] || [_nameTextField.text isEqualToString:@""]) {
        [self showTip:@"Email and user name cannot be empty!"];
    }
    [group saveCurrentUserWithEmail:_emailTextField.text name:_nameTextField.text];
    [self performSegueWithIdentifier:@"initGroupSegue" sender:self];
}

@end
