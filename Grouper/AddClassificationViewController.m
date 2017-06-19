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
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ %@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao = [DaoManager sharedInstance];
}

#pragma mark - Action
- (IBAction)save:(id)button {
    if (DEBUG) {
        NSLog(@"Running %@ %@'", self.class, NSStringFromSelector(_cmd));
    }
    NSString *cname = _cnameTextField.text;
    if ([cname isEqualToString:@""]) {
        [self showWarning:@"Classification name is empty!"];
        return;
    }
    User *user = [[GroupManager sharedInstance] currentUser];
    Classification *classification = [dao.classificationDao saveWithName:cname creator:user.email];
    [[SendManager sharedInstance] update:classification];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
