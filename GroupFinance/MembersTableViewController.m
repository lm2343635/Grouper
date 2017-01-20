//
//  MembersTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 07/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "MembersTableViewController.h"
#import "DaoManager.h"
#import "GroupTool.h"
#import "InternetTool.h"
#import <MJRefresh/MJRefresh.h>

@interface MembersTableViewController ()

@end

@implementation MembersTableViewController {
    DaoManager * dao;
    NSArray *members;
    User *owner;
    User *currentUser;
    GroupTool *group;
    NSDictionary *managers;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    group = [GroupTool sharedInstance];
    dao = [DaoManager sharedInstance];
    managers = [InternetTool getSessionManagers];
    
    currentUser = [dao.userDao currentUser];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refreshMemberList];
    }];
    
    if (group.initial == InitialFinished) {
        _noMembersView.hidden = YES;
        [self loadMembersInfo];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewWillAppear:animated];
//    group = [[GroupTool alloc] init];
    managers = [InternetTool getSessionManagers];
}

- (void)refreshMemberList {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (group.initial != InitialFinished) {
        [self.tableView.mj_header endRefreshing];
        return;
    }
    NSString *address0 = [group.servers.allKeys objectAtIndex:0];
    //Reload user info
    [managers[address0] GET:[InternetTool createUrl:@"user/list" withServerAddress:address0]
                 parameters:nil
                   progress:nil
                    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                        if ([response statusOK]) {
                            NSObject *result = [response getResponseResult];
                            NSArray *users = [result valueForKey:@"users"];
                            for(NSObject *user in users) {
                                if ([currentUser.uid isEqualToString:[user valueForKey:@"id"]]) {
                                    continue;
                                }
                                [dao.userDao saveOrUpdateWithJSONObject:user fromUntrustedServer:YES];
                            }
                            
                            group.members = users.count;
                            if (group.members > 0) {
                                _noMembersView.hidden = YES;
                                [self loadMembersInfo];
                            }
                            
                            [self.tableView reloadData];
                            [self.tableView.mj_header endRefreshing];
                        }
                    }
                    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        InternetResponse *response = [[InternetResponse alloc] initWithError:error];
                        switch ([response errorCode]) {
                            case ErrorMasterOrAccessKey:
                                [self.tableView.mj_header endRefreshing];
                                break;
                        }
                    }];

}

- (void)loadMembersInfo {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    members = [dao.userDao findMembersExceptOwner:group.owner];
    owner = [dao.userDao getByUserId:group.owner];
    for (User *member in members) {
        member.picture = [NSData dataWithContentsOfURL:[NSURL URLWithString:member.pictureUrl]];
    }
    owner.picture = [NSData dataWithContentsOfURL:[NSURL URLWithString:owner.pictureUrl]];
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
    if (group.initial != InitialFinished) {
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
    return (group.initial != InitialFinished)? nil: @" ";
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
@end
