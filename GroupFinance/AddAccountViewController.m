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

@interface AddAccountViewController ()

@end

@implementation AddAccountViewController {
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
    NSString *aname=_anameTextField.text;
    if([aname isEqualToString:@""]) {
        [AlertTool showAlert:@"Account name is empty!"];
        return;
    }
    AccountBook *usingAccountBook=[dao.accountBookDao getUsingAccountBook];
    if(usingAccountBook==nil) {
        [AlertTool showAlert:@"Choose an using account book at first!"];
        return;
    }
    [dao.accountDao saveWithName:aname inAccountBook:usingAccountBook];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
