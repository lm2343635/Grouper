//
//  AddMemberViewController.m
//  GroupFinance
//
//  Created by lidaye on 22/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AddMemberViewController.h"
#import "DaoManager.h"
#import "AppDelegate.h"

@interface AddMemberViewController ()

@property (nonatomic, strong) AppDelegate *delegate;
@property (nonatomic, strong) NSMutableArray *connectedDevices;

-(void)peerDidChangeStateWithNotification: (NSNotification *)notification;

@end

@implementation AddMemberViewController {

    DaoManager *dao;
    User *currentUser;
    
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }

    dao = [[DaoManager alloc] init];
    currentUser = [dao.userDao getUsingUser];
    
    _delegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [_delegate.mcManager setupPeerAndSessionWithDisplayName:currentUser.name];
    [_delegate.mcManager advertiseSelf:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCDidChangeStateNotification"
                                               object:nil];
    _connectedDevices=[[NSMutableArray alloc] init];
}

#pragma mark - UITableViewDataSource
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
    return _connectedDevices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"deviceIdentifier"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [_connectedDevices objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = @"Invite";
    return cell;
}


#pragma mark - MCBrowserViewControllerDelegate
-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [_delegate.mcManager.browserViewController dismissViewControllerAnimated:YES
                                                                  completion:nil];
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [_delegate.mcManager.browserViewController dismissViewControllerAnimated:YES
                                                                  completion:nil];
}

#pragma mark - Action
- (IBAction)browseForDevices:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [_delegate.mcManager setupMCBrowser];
    [_delegate.mcManager.browserViewController setDelegate:self];
    [self presentViewController:_delegate.mcManager.browserViewController
                       animated:YES
                     completion:nil];
}

#pragma mark - Notification
- (void)peerDidChangeStateWithNotification:(NSNotification *)notification {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    if (state != MCSessionStateConnecting) {
        if (state == MCSessionStateConnected) {
            [_connectedDevices addObject:peerDisplayName];
        } else if (state == MCSessionStateNotConnected) {
            if(_connectedDevices.count > 0) {
                [_connectedDevices removeObjectAtIndex:[_connectedDevices indexOfObject:peerDisplayName]];
            }
        }
        NSLog(@"Connected devices: %@", _connectedDevices);
        [_devicesTableView reloadData];

    }
}

@end
