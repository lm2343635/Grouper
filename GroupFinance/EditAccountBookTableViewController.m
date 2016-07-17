//
//  EditAccountBookTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 7/16/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "EditAccountBookTableViewController.h"
#import "AlertTool.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface EditAccountBookTableViewController ()

@end

@implementation EditAccountBookTableViewController {
    DaoManager *dao;
    NSArray *cooperaters;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao = [[DaoManager alloc] init];
    self.title = _accountBook.abname;
    cooperaters = [_accountBook getCooperatersWithJSONArray];
    //Close Edit for cooperaters
    if(![_accountBook.owner isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]) {
        _accountBookNameTextField.enabled = NO;
        _saveBarButtonItem.enabled = NO;
    }
    
//    _cooperatersCount = 0;
//    [self addObserver:self forKeyPath:@"cooperatersCount" options:NSKeyValueObservingOptionNew context:nil];
//    [self loadCooperaters];
}

- (void)viewWillAppear:(BOOL)animated {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewWillAppear:animated];
    [_accountBookNameTextField setText:_accountBook.abname];
}

- (void)loadCooperaters {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    for(NSString *userId in [_accountBook getCooperatersWithJSONArray]) {
        User *user = [dao.userDao getByUserId:userId];
        if(user != nil) {
            _cooperatersCount ++;
            return;
        }

        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:userId
                                                                       parameters:@{@"fields": @"picture, email, name, gender"}
                                                                       HTTPMethod:@"GET"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if(DEBUG) {
                NSLog(@"Get facebook user info: %@", result);
            }
            [dao.userDao saveOrUpdateWithJSONObject:result];
            _cooperatersCount ++;
        }];
    }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if([keyPath isEqualToString:@"cooperatersCount"]) {
        
    }
}

#pragma mark - Action
- (IBAction)saveEidt:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSString *accountBookName =_accountBookNameTextField.text;
    if([accountBookName isEqualToString:@""]) {
        [AlertTool showAlertWithTitle:@"Warning"
                           andContent:@"Account book name empty!"
                     inViewController:self];
    } else {
        _accountBook.abname=accountBookName;
        [dao saveContext];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)setAsUsing:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [dao.accountBookDao setUsingAccountBook:_accountBook];
    [AlertTool showAlertWithTitle:@"Tip"
                       andContent:[NSString stringWithFormat:@"%@ is using account book now!", _accountBook.abname]
                 inViewController:self];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return cooperaters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cooperaterIdentifier"
                                                            forIndexPath:indexPath];
    UILabel *cooperaterNameLebel = (UILabel *)[cell viewWithTag:2];
    cooperaterNameLebel.text = [cooperaters objectAtIndex:indexPath.row];
    return cell;
}

@end
