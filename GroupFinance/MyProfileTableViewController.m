//
//  MyProfileTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 7/14/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "MyProfileTableViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "DaoManager.h"

@interface MyProfileTableViewController ()

@end

@implementation MyProfileTableViewController {
    DaoManager *dao;
    User *user;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao = [[DaoManager alloc] init];
    user = [dao.userDao getUsingUser];
    if (user.picture == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            user.picture = [NSData dataWithContentsOfURL:[NSURL URLWithString:user.pictureUrl]];
        });
        dispatch_async(dispatch_get_main_queue(), ^{
             _profilePhotoImageView.image = [UIImage imageWithData:user.picture];
        });
    }
    _profilePhotoImageView.image = [UIImage imageWithData:user.picture];
    _nameLabel.text = user.name;
    _emailLabel.text = user.email;
    _genderLabel.text = user.gender;
}

#pragma mark - Action
- (IBAction)logout:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"login"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    //Clear header view color
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return 0.1;
}

@end
