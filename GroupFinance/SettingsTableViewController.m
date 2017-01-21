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
    UIAlertController *clearAlertController;
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
    
    [self initClearAlertController];
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

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSLog(@"indexPath.section == %ld && indexPath.row == %ld", (long)indexPath.section, (long)indexPath.row);
    if (indexPath.section == 2 && indexPath.row == 1) {
        [self presentViewController:clearAlertController animated:YES completion:nil];
    }
}

#pragma mark - Action
- (void)initClearAlertController {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    clearAlertController = [UIAlertController alertControllerWithTitle:@"Clear Share ID Cache"
                                                          message:nil
                                                   preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *clear = [UIAlertAction actionWithTitle:@"Clear Now!"
                                                    style:UIAlertActionStyleDestructive
                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                      [self clearShareIdCache];
                                                  }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [clearAlertController addAction:clear];
    [clearAlertController addAction:cancel];
}

- (void)clearShareIdCache {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
}

@end
