//
//  JoinGroupViewController.m
//  Grouper
//
//  Created by 李大爷的电脑 on 04/06/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "JoinGroupViewController.h"
#import "AlertTool.h"
#import "Grouper.h"

@interface JoinGroupViewController ()

@end

@implementation JoinGroupViewController {
    GroupManager *group;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    group = [GroupManager sharedInstance];
}

- (void)viewWillAppear:(BOOL)animated {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // Update devices table.
    [_devicesTableView reloadData];
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return 0.1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return group.connectedPeers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"deviceIdentifier"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [[group.connectedPeers objectAtIndex:indexPath.row] displayName];
    return cell;
}

#pragma mark - Action
- (IBAction)browseForDevices:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [group openDeviceBroswerIn:self];
}

#pragma mark - Notification
- (void)didReceiveJoinGroupMessage:(NSNotification *)notification {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [AlertTool showAlertWithTitle:@"Tip"
                       andContent:[GroupManager getJoinGroupMessage:notification]
                 inViewController:self];
}

@end
