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
    User *currentUser;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ %@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao = [DaoManager sharedInstance];
    currentUser = [[GroupManager sharedInstance] currentUser];
}

#pragma mark - Action
- (IBAction)save:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ %@'", self.class, NSStringFromSelector(_cmd));
    }
    NSString *aname = _anameTextField.text;
    if ([aname isEqualToString:@""]) {
        [self showTip:@"Account name is empty!"];
        return;
    }
    Account *account = [dao.accountDao saveWithName:aname creator:currentUser.email];
    [[SendManager sharedInstance] update:account];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
