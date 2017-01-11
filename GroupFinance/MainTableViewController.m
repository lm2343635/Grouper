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
#import "ReceiveTool.h"

@interface MainTableViewController ()

@end

@implementation MainTableViewController {
    GroupTool *group;
    NSDictionary *managers;
    int accessedServers;
    
    NSMutableDictionary *loadingActivityIndicatorViews;
    NSMutableDictionary *stateImageViews;
    UIImageView *syncImageView;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    
    group = [[GroupTool alloc] init];
    managers = [InternetTool getSessionManagers];
    
    loadingActivityIndicatorViews = [[NSMutableDictionary alloc] init];
    stateImageViews = [[NSMutableDictionary alloc] init];

    [self checkServerState];
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
        cell = [self createTitleCellWithImageName:@"servers" title:@"Untrusted Servers State" inIndexPath:indexPath];
    } else if (NSLocationInRange(indexPath.row, NSMakeRange(1, group.serverCount))) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"serverIdentifier" forIndexPath:indexPath];
        UILabel *serverAddressLabel = (UILabel *)[cell viewWithTag:1];
        serverAddressLabel.text = [group.servers.allKeys objectAtIndex:indexPath.row - 1];
        if (indexPath.row - 1 == group.servers.allKeys.count - 1) {
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
        
        [stateImageViews setObject:(UIImageView *)[cell viewWithTag:2]
                   forKey:serverAddressLabel.text];
        [loadingActivityIndicatorViews setObject:(UIActivityIndicatorView *)[cell viewWithTag:3]
                     forKey:serverAddressLabel.text];
    } else if (indexPath.row == 1 + group.serverCount) {
        cell = [self createTitleCellWithImageName:@"sync" title:@"Data Synchronization" inIndexPath:indexPath];
        syncImageView = (UIImageView *)[cell viewWithTag:1];
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

- (void)checkServerState {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self.checkState = 0;
    [self addObserver:self
           forKeyPath:@"checkState"
              options:NSKeyValueObservingOptionNew
              context:nil];
    for (NSString *address in group.servers.allKeys) {
        [managers[address] GET:[InternetTool createUrl:@"user/state" withServerAddress:address]
                    parameters:nil
                      progress:nil
                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                           InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                           if ([response statusOK]) {
                               BOOL state = [[[response getResponseResult] valueForKey:@"ok"] boolValue];
                               if (state) {
                                   accessedServers ++;
                               }
                               [self showState:state forServer:address];
                               self.checkState ++;
                           }
                       }
                       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                           [self showState:NO forServer:address];
                           self.checkState ++;
                       }];
    }
}

- (void)showState:(BOOL)state forServer:(NSString *)address {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UIImageView *stateImageView = [stateImageViews objectForKey:address];
    UIActivityIndicatorView *loadingActivityIndicatorView = [loadingActivityIndicatorViews objectForKey:address];
    stateImageView.highlighted = !state;
    stateImageView.hidden = NO;
    [loadingActivityIndicatorView stopAnimating];
}

- (void)dataSync {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }

    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: - M_PI * 2.0];
    rotationAnimation.duration = 2;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 100000;
    [syncImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    ReceiveTool *receive = [[ReceiveTool alloc] init];
    [receive receive];
}

#pragma mark - Key Value Observe
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([keyPath isEqualToString:@"checkState"]) {
        if (self.checkState == group.serverCount) {
            if (DEBUG) {
                NSLog(@"All servers' state have been checked.");
            }
            [self removeObserver:self forKeyPath:@"checkState"];
            // If threshold is k in a secret sharing scheme f(k, n),
            // sync method can be invoked after accessing more than k untrusted servers.
            if (accessedServers >= group.threshold) {
                if (DEBUG) {
                    NSLog(@"Accessed %d servers, call sync method.", accessedServers);
                }
                [self dataSync];
            }
        }
    }
}

@end
