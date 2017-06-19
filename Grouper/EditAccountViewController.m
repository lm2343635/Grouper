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
    User *currentUser;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao = [DaoManager sharedInstance];
    currentUser = [[GroupManager sharedInstance] currentUser];
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
    NSString *aname = _anameTextField.text;
    if([aname isEqualToString:@""]) {
        [self showWarning:@"Account name is empty!"];
        return;
    }
    // Update account.
    _account.aname = aname;
    _account.updater = currentUser.email;
    _account.updateAt = [NSDate date];
    [dao saveContext];
    
    // Send shares.
    [[SendManager sharedInstance] update:_account];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
