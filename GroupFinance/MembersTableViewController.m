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

@interface MembersTableViewController ()

@end

@implementation MembersTableViewController {
    MCManager *mcManager;
    NSMutableArray *connectedDevices;
    DaoManager * dao;
    User *currentUser;
    NSArray *members;
    User *owner;
    GroupTool *group;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    group = [[GroupTool alloc] init];
    dao = [[DaoManager alloc] init];
    currentUser = [dao.userDao getUsingUser];
    
    if (group.members > 0) {
        members = [dao.userDao findMembersExceptOwner:group.owner];
        owner = [dao.userDao getByUserId:group.owner];
        _noMembersView.hidden = YES;
    }
    
    
    mcManager = [MCManager getSingleInstance];
    [mcManager setupPeerAndSessionWithDisplayName:currentUser.name];
    [mcManager advertiseSelf:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCDidChangeStateNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveDataWithNotification:)
                                                 name:@"MCDidReceiveDataNotification"
                                               object:nil];
    connectedDevices = [[NSMutableArray alloc] init];
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
    if (group.members ==0) {
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
    return (group.members == 0)? nil: @" ";
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

#pragma mark - MCBrowserViewControllerDelegate
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [mcManager.browserViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [mcManager.browserViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Action
- (IBAction)browseForDevices:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [mcManager setupMCBrowser];
    [mcManager.browserViewController setDelegate:self];
    [self presentViewController:mcManager.browserViewController animated:YES completion:nil];
}

#pragma mark - Notification
- (void)peerDidChangeStateWithNotification:(NSNotification *)notification {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state=[[[notification userInfo] objectForKey:@"state"] intValue];
    NSLog(@"peerDisplayName = %@, state = %ld", peerDisplayName, state);
    NSLog(@"%@", mcManager.session.connectedPeers);
    if (state == MCSessionStateConnected) {
        NSError *error = nil;
        [mcManager.session sendData:[currentUser.uid dataUsingEncoding:NSUTF8StringEncoding]
                            toPeers:mcManager.session.connectedPeers
                           withMode:MCSessionSendDataReliable
                              error:&error];
        if (error) {
            NSLog(@"Error in mutipeer sending: %@", error.localizedDescription);
        }
    }
}

-(void)didReceiveDataWithNotification:(NSNotification *)notification {
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSString *receivedText = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    NSLog(@"Received text %@", receivedText);
}

@end
