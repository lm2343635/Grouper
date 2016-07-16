//
//  EditAccountBookViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/15/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "EditAccountBookViewController.h"
#import "AlertTool.h"

@interface EditAccountBookViewController ()

@end

@implementation EditAccountBookViewController {
    DaoManager *dao;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao = [[DaoManager alloc] init];
    self.title = _accountBook.abname;
}

- (void)viewWillAppear:(BOOL)animated {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewWillAppear:animated];
    [_accountBookNameTextField setText:_accountBook.abname];
}


#pragma mark - Action
- (IBAction)saveEidt:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSString *accountBookName =_accountBookNameTextField.text;
    if([accountBookName isEqualToString:@""]) {
        [AlertTool showAlertWithTitle:@"Warning"
                           andContent:@"Account book name empty!"
                     inViewController:self];
    } else {
        _accountBook.abname=accountBookName;
        [dao saveContext];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)setAsUsing:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [dao.accountBookDao setUsingAccountBook:_accountBook];
    [AlertTool showAlertWithTitle:@"Tip"
                       andContent:[NSString stringWithFormat:@"%@ is using account book now!", _accountBook.abname]
                 inViewController:self];
}

@end
