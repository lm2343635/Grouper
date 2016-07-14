//
//  AddAccountBookViewController.m
//  GroupFinance
//
//  Created by lidaye on 4/26/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AddAccountBookViewController.h"
#import "DaoManager.h"

@interface AddAccountBookViewController ()

@end

@implementation AddAccountBookViewController {
    DaoManager *dao;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao=[[DaoManager alloc] init];
}

- (IBAction)save:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [dao.accountBookDao saveWithName:_abnameTextField.text
                            forOwner:[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
