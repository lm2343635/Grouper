//
//  EditAccountViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "EditAccountViewController.h"
#import "UIViewController+Extension.h"
#import "Grouper.h"

@interface EditAccountViewController ()

@end

@implementation EditAccountViewController {
    DaoManager *dao;
    Grouper *grouper;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao = [DaoManager sharedInstance];
    grouper = [Grouper sharedInstance];
}

- (void)viewWillAppear:(BOOL)animated {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [_anameTextField setText:_account.aname];
}

#pragma mark - Action
- (IBAction)save:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if([_anameTextField.text isEqualToString:@""]) {
        [self showWarning:@"Account name is empty!"];
        return;
    }
    
    // Update account.
    _account.aname = _anameTextField.text;
    _account.updater = grouper.group.currentUser.email;
    _account.updateAt = [NSDate date];
    [dao saveContext];
    
    // Send shares.
    [grouper.sender update:_account];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
