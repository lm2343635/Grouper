//
//  AddAccountViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AddAccountViewController.h"
#import "DaoManager.h"
#import "AlertTool.h"
#import "SendManager.h"

@interface AddAccountViewController ()

@end

@implementation AddAccountViewController {
    DaoManager *dao;
    User *currentUser;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ %@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao = [DaoManager sharedInstance];
    currentUser = [dao.userDao currentUser];
}

#pragma mark - Action
- (IBAction)save:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ %@'", self.class, NSStringFromSelector(_cmd));
    }
    NSString *aname = _anameTextField.text;
    if([aname isEqualToString:@""]) {
        [AlertTool showAlertWithTitle:@"Warning"
                           andContent:@"Account name is empty!"
                     inViewController:self];
        return;
    }
    Account *account = [dao.accountDao saveWithName:aname creator:currentUser.userId];
    [[SendManager sharedInstance] update:account];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
