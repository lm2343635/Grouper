//
//  MainTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 09/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "MainTableViewController.h"
#import "GroupTool.h"
#import "InternetTool.h"

@interface MainTableViewController ()

@end

@implementation MainTableViewController {
    GroupTool *group;
    NSDictionary *managers;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    
    group = [[GroupTool alloc] init];
    managers = [InternetTool getSessionManagers];

}

#pragma mark - Table view data source]
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return 0.01;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return group.serverCount + 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (indexPath.row == 0) {
        return 70.0;
    } else if (NSLocationInRange(indexPath.row, NSMakeRange(1, group.serverCount))) {
        return 50.0;
    } else if (indexPath.row == 1 + group.serverCount) {
        return 70.0;
    }
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UITableViewCell *cell = nil;
    if (indexPath.row == 0) {
        cell = [self createTitleCellWithImageName:@"servers" title:@"Untrusted Servers" inIndexPath:indexPath];
    } else if (NSLocationInRange(indexPath.row, NSMakeRange(1, group.serverCount))) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"serverIdentifier" forIndexPath:indexPath];
        UILabel *serverAddressLabel = (UILabel *)[cell viewWithTag:1];
        serverAddressLabel.text = [group.servers.allKeys objectAtIndex:indexPath.row - 1];
        if (indexPath.row - 1 == group.servers.allKeys.count - 1) {
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
    } else if (indexPath.row == 1 + group.serverCount) {
        cell = [self createTitleCellWithImageName:@"sync" title:@"Data Synchronization" inIndexPath:indexPath];
    }
    return cell;
}


#pragma mark - Service
- (UITableViewCell *)createTitleCellWithImageName:(NSString *)image
                                            title:(NSString *)title
                                      inIndexPath:(NSIndexPath *)indexPath{
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"titleIdentifier" forIndexPath:indexPath];
    UIImageView *symbolImageView = (UIImageView *)[cell viewWithTag:1];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:2];
    symbolImageView.image = [UIImage imageNamed:image];
    titleLabel.text = title;
    return cell;
}

@end
