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

@interface AddShopViewController ()

@end

@implementation AddShopViewController {
    DaoManager *dao;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ %@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao=[[DaoManager alloc] init];
}

#pragma mark - Action
- (IBAction)save:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ %@'", self.class, NSStringFromSelector(_cmd));
    }
    NSString *sname=_snameTextField.text;
    if([sname isEqualToString:@""]) {
        [AlertTool showAlertWithTitle:@"Warning"
                           andContent:@"Shop name is empty!"
                     inViewController:self];
        return;
    }
    AccountBook *usingAccountBook=[dao.accountBookDao getUsingAccountBook];
    if(usingAccountBook==nil) {
        [AlertTool showAlertWithTitle:@"Tip"
                           andContent:@"Choose an using account book at first!"
                     inViewController:self];
        return;
    }
    [dao.shopDao saveWithName:sname inAccountBook:usingAccountBook];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
