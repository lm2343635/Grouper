//
//  MembersTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 07/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "MembersTableViewController.h"
#import "Grouper.h"

@interface MembersTableViewController ()

@end

@implementation MembersTableViewController {
    GrouperDaoManager *dao;
    GroupManager *group;
    
    NSArray *members;
    User *owner;
    User *currentUser;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    group = [GroupManager sharedInstance];
    dao = [GrouperDaoManager sharedInstance];
    
    // Remove inviting member button if this user is not group owner.
    if (!group.isOwner) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewWillAppear:animated];
    [self loadMembersInfo];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return 0.1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (group.defaults.initial != InitialFinished) {
        return 0;
    }
    return (section == 0)? 1: members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"membersIdentifier"
                                                            forIndexPath:indexPath];
    User *user = (indexPath.section == 0)? owner: [members objectAtIndex:indexPath.row];

    UILabel *nameEmailLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *nodeLabel = (UILabel *)[cell viewWithTag:2];
    nameEmailLabel.text = [NSString stringWithFormat:@"%@ (%@)", user.name, user.email];
    nodeLabel.text = user.node;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return (group.defaults.initial != InitialFinished)? nil: @" ";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    headerView.backgroundColor = [UIColor clearColor];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, headerView.bounds.size.width - 15, headerView.bounds.size.height)];
    nameLabel.text = (section == 0) ? @"Group Owner" : @"Group Members";
    [headerView addSubview:nameLabel];
    return headerView;
}

#pragma mark - Action
- (IBAction)exitMembers:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Service
- (void)loadMembersInfo {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    members = [dao.userDao findMembersExceptOwner:group.defaults.owner];
    owner = [dao.userDao getByEmail:group.defaults.owner];
    [self.tableView reloadData];
}

@end
