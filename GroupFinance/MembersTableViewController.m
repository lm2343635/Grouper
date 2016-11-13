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
    User *currentUser;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    
    dao = [[DaoManager alloc] init];
    currentUser = [dao.userDao getUsingUser];
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
