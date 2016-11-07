//
//  MembersTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 07/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "MembersTableViewController.h"
#import "DaoManager.h"

@interface MembersTableViewController ()

@end

@implementation MembersTableViewController {
    MCManager *mcManager;
    NSMutableArray *connectedDevices;
    DaoManager * dao;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    
    dao = [[DaoManager alloc] init];
    User *currentUser = [dao.userDao getUsingUser];
    mcManager = [MCManager getSingleInstance];
    [mcManager setupPeerAndSessionWithDisplayName:currentUser.name];
    [mcManager advertiseSelf:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCDidChangeStateNotification"
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return connectedDevices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"membersIdentifier"
                                                            forIndexPath:indexPath];
    UILabel *name = (UILabel *)[cell viewWithTag:2];
    name.text = [connectedDevices objectAtIndex:indexPath.row];
    return cell;
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
    if (state != MCSessionStateConnecting) {
        if (state == MCSessionStateConnected) {
            [connectedDevices addObject:peerDisplayName];
        } else if (state == MCSessionStateNotConnected) {
            if (connectedDevices.count > 0) {
                [connectedDevices removeObjectAtIndex:[connectedDevices indexOfObject:peerDisplayName]];
            }
        }
        NSLog(@"Now, connectedDevices are %@", connectedDevices);
        [self.tableView reloadData];

    }
}
@end
