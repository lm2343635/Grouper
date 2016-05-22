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
    dao=[[DaoManager alloc] init];
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
    NSString *accountBookName=_accountBookNameTextField.text;
    if([accountBookName isEqualToString:@""]) {
        UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"Tip"
                                                                               message:@"Account book name empty!"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"OK"
                                                             style:UIAlertActionStyleCancel
                                                           handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
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
    NSLog(@"%@", _accountBook.using);
    [AlertTool showAlert:[NSString stringWithFormat:@"%@ is using account book now!", _accountBook.abname]];
}
@end
