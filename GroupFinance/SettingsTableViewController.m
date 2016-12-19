//
//  SettingsTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 25/09/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "GroupTool.h"
#import "AlertTool.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController {
    GroupTool *group;
}

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewWillAppear:animated];
    group = [[GroupTool alloc] init];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }

}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (group.groupId == nil &&
        ([identifier isEqualToString:@"templatesSegue"] || [identifier isEqualToString:@"classificationsSegue"]
         || [identifier isEqualToString:@"shopsSegue"] || [identifier isEqualToString:@"accountsSegue"])) {
        [AlertTool showAlertWithTitle:@"Tip"
                           andContent:@"Join or create a group at first!"
                     inViewController:self];
        return NO;
    }
    return YES;
}

#pragma mark - Table view data source
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    //Clear header view color
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return 0.1;
}

@end
