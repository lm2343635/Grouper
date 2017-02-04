//
//  EditAccountViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "EditAccountViewController.h"
#import "AlertTool.h"
#import "SendTool.h"

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
    currentUser = [dao.userDao currentUser];
}

- (void)viewWillAppear:(BOOL)animated {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [_anameTextField setText:_account.aname];
}

#pragma mark - Action
- (IBAction)save:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSString *aname = _anameTextField.text;
    if([aname isEqualToString:@""]) {
        [AlertTool showAlertWithTitle:@"Warning"
                           andContent:@"Account name is empty!"
                     inViewController:self];
        return;
    }
    // Update account.
    _account.aname = aname;
    _account.updater = currentUser.uid;
    _account.updateAt = [NSDate date];
    [dao saveContext];
    
    // Send shares.
    [[SendTool sharedInstance] update:_account];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
