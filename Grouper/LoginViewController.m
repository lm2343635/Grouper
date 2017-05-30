//
//  LoginViewController.m
//  GroupFinance
//
//  Created by lidaye on 6/12/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "LoginViewController.h"
#import "DaoManager.h"
#import "GroupManager.h"

@interface LoginViewController ()

@end

@implementation LoginViewController {
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

}

#pragma mark - Action

- (IBAction)setUserInfo:(id)sender {
    
}

@end
