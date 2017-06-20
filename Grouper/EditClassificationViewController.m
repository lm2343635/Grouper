//
//  EditClassificationViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "EditClassificationViewController.h"
#import "UIViewController+Extension.h"
#import "Grouper.h"

@interface EditClassificationViewController ()

@end

@implementation EditClassificationViewController {
    DaoManager *dao;
    Grouper *grouper;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao = [DaoManager sharedInstance];
    grouper = [Grouper sharedInstance];
}

- (void)viewWillAppear:(BOOL)animated {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [_cnameTextField setText:_classification.cname];
}

#pragma mark - Action
- (IBAction)save:(id)saveButton {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSString *cname = _cnameTextField.text;
    if ([cname isEqualToString:@""]) {
        [self showWarning:@"Classification name is empty!"];
        return;
    }
    // Update classification.
    _classification.cname = cname;
    _classification.update = grouper.group.currentUser.email;
    _classification.updateAt = [NSDate date];
    [dao saveContext];
    
    // Send shares to untrusted servers.
    [grouper.sender update:_classification];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
