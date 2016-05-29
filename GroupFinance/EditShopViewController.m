//
//  EditShopViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "EditShopViewController.h"
#import "AlertTool.h"

@interface EditShopViewController ()

@end

@implementation EditShopViewController {
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
    [_snameTextField setText:_shop.sname];
}

#pragma mark - Action
- (IBAction)save:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSString *sname=_snameTextField.text;
    if([sname isEqualToString:@""]) {
        [AlertTool showAlert:@"Shop name is empty!"];
        return;
    }
    _shop.sname=sname;
    [dao saveContext];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
