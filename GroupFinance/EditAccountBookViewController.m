//
//  EditAccountBookViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/15/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "EditAccountBookViewController.h"
#import "AppDelegate.h"

@interface EditAccountBookViewController ()

@end

@implementation EditAccountBookViewController {
    AppDelegate *delegate;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    delegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
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
        [delegate.managedObjectContext save:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
