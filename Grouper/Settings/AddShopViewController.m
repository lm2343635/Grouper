//
//  AddShopViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AddShopViewController.h"
#import "UIViewController+Extension.h"
#import "Grouper.h"
#import "DaoManager.h"

@interface AddShopViewController ()

@end

@implementation AddShopViewController {
    DaoManager *dao;
    Grouper *grouper;
}

- (void)viewDidLoad {
    if (DEBUG) {
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
    if ([_snameTextField.text isEqualToString:@""]) {
        [self showWarning:@"Shop name is empty!"];
        return;
    }
    // Save shop.
    Shop *shop = [dao.shopDao saveWithName:_snameTextField.text
                                   creator:grouper.group.currentUser.email];
    // Send shares.
    [grouper.sender update:shop];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
