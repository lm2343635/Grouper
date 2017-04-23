//
//  MembersTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 07/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "MembersTableViewController.h"
#import "DaoManager.h"
#import "GroupManager.h"
#import <MJRefresh/MJRefresh.h>

@interface MembersTableViewController ()

@end

@implementation MembersTableViewController {
    DaoManager *dao;
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
    dao = [DaoManager sharedInstance];
    
    currentUser = [dao.userDao currentUser];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [group refreshMemberListWithCompletion:^(BOOL success) {
            [self.tableView.mj_header endRefreshing];
            if (success) {
                if (group.members > 0) {
                    _noMembersView.hidden = YES;
                    [self loadMembersInfo];
                }
                
                [self.tableView reloadData];
            }
        }];
    }];
    
    if (group.defaults.initial == InitialFinished) {
        _noMembersView.hidden = YES;
        [self loadMembersInfo];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewWillAppear:animated];
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
    UIImageView *pictureImageView = (UIImageView *)[cell viewWithTag:1];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *emailLabel = (UILabel *)[cell viewWithTag:3];
    UIImageView *genderImageView = (UIImageView *)[cell viewWithTag:4];
    pictureImageView.image = [UIImage imageWithData:user.picture];
    nameLabel.text = user.name;
    emailLabel.text = user.email;
    genderImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"gender_%@", user.gender]];
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
    nameLabel.text = (section == 0)? @"Group Owner": @"Group Members";
    [headerView addSubview:nameLabel];
    return headerView;
}

#pragma mark - Action
- (IBAction)refreshMembers:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (group.members == 0) {
        return;
    }
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - Service
- (void)loadMembersInfo {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    members = [dao.userDao findMembersExceptOwner:group.defaults.owner];
    owner = [dao.userDao getByUserId:group.defaults.owner];
    for (User *member in members) {
        member.picture = [NSData dataWithContentsOfURL:[NSURL URLWithString:member.pictureUrl]];
    }
    owner.picture = [NSData dataWithContentsOfURL:[NSURL URLWithString:owner.pictureUrl]];
}

@end
