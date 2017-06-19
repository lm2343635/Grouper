//
//  EditShopViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "EditShopViewController.h"
#import "UIViewController+Extension.h"
#import "Grouper.h"

@interface EditShopViewController ()

@end

@implementation EditShopViewController {
    DaoManager *dao;
    User *currentUser;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao = [DaoManager sharedInstance];
    currentUser = [[GroupManager sharedInstance] currentUser];
}

- (void)viewWillAppear:(BOOL)animated {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [_snameTextField setText:_shop.sname];
}

#pragma mark - Action
- (IBAction)save:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSString *sname = _snameTextField.text;
    if ([sname isEqualToString:@""]) {
        [self showWarning:@"Shop name is empty!"];
        return;
    }
    // Update shop.
    _shop.sname = sname;
    _shop.updater = currentUser.email;
    _shop.updateAt = [NSDate date];
    [dao saveContext];
    
    // Send shares to untrusted servers.
    [[SendManager sharedInstance] update:_shop];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
