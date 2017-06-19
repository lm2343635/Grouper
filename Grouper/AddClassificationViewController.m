//
//  AddClassificationViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AddClassificationViewController.h"
#import "DaoManager.h"
#import "UIViewController+Extension.h"
#import "Grouper.h"

@interface AddClassificationViewController ()

@end

@implementation AddClassificationViewController {
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
- (IBAction)save:(id)button {
    if (DEBUG) {
        NSLog(@"Running %@ %@'", self.class, NSStringFromSelector(_cmd));
    }

    if ([ _cnameTextField.text isEqualToString:@""]) {
        [self showWarning:@"Classification name is empty!"];
        return;
    }

    Classification *classification = [dao.classificationDao saveWithName: _cnameTextField.text
                                                                 creator:grouper.group.currentUser.email];
    [grouper.sender update:classification];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
