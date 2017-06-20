//
//  AddAccountViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AddAccountViewController.h"
#import "DaoManager.h"
#import "UIViewController+Extension.h"
#import "Grouper.h"

@interface AddAccountViewController ()

@end

@implementation AddAccountViewController {
    DaoManager *dao;
    Grouper *grouper;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ %@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao = [DaoManager sharedInstance];
    grouper = [Grouper sharedInstance];
}

#pragma mark - Action
- (IBAction)save:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ %@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([_anameTextField.text isEqualToString:@""]) {
        [self showTip:@"Account name is empty!"];
        return;
    }
    Account *account = [dao.accountDao saveWithName:_anameTextField.text
                                            creator:grouper.group.currentUser.email];
    [grouper.sender update:account];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
