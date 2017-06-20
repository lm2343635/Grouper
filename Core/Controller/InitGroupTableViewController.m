//
//  InitGroupTableViewController.m
//  Grouper
//
//  Created by lidaye on 03/06/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "InitGroupTableViewController.h"
#import "Grouper.h"

@interface InitGroupTableViewController ()

@end

@implementation InitGroupTableViewController {
    GroupManager *group;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    
    group = [GroupManager sharedInstance];
    if (group.currentUser != nil) {
        _nameLabel.text = group.currentUser.name;
        _emailLabel.text = group.currentUser.email;
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return 0.01;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (indexPath.row == 2) {
        [self.navigationController popViewControllerAnimated:true];
    }
}


@end
