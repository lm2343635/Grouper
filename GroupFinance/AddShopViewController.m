//
//  AddShopViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AddShopViewController.h"
#import "DaoManager.h"
#import "AlertTool.h"
#import "SendTool.h"

@interface AddShopViewController ()

@end

@implementation AddShopViewController {
    DaoManager *dao;
    User *currentUser;
}

- (void)viewDidLoad {
    if (DEBUG) {
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
    NSString *sname=_snameTextField.text;
    if([sname isEqualToString:@""]) {
        [AlertTool showAlertWithTitle:@"Warning"
                           andContent:@"Shop name is empty!"
                     inViewController:self];
        return;
    }
    // Save shop.
    Shop *shop = [dao.shopDao saveWithName:sname creator:currentUser.uid];
    // Send shares.
    [[SendTool sharedInstance] sendSharesWithObject:shop];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
