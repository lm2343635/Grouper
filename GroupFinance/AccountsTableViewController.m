//
//  AccountsTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AccountsTableViewController.h"
#import "DaoManager.h"

@interface AccountsTableViewController ()

@end

@implementation AccountsTableViewController {
    DaoManager *dao;
    NSMutableArray *accounts;
    Account *selectedAccount;
    NSString *userId;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao = [[DaoManager alloc] init];
    userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
}

- (void)viewWillAppear:(BOOL)animated {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    accounts = [NSMutableArray arrayWithArray:[dao.accountDao findAll]];
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return accounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Account *account = [accounts objectAtIndex:indexPath.row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accountIndentifer" forIndexPath:indexPath];
    UILabel *anameLabel = (UILabel *)[cell viewWithTag:1];
    anameLabel.text = account.aname;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    selectedAccount = [accounts objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"editAccountSegue" sender:self];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Account *account=[accounts objectAtIndex:indexPath.row];
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        [dao.context deleteObject:account];
        [dao saveContext];
        [accounts removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if([segue.identifier isEqualToString:@"editAccountSegue"]) {
        UIViewController *controller=[segue destinationViewController];
        [controller setValue:selectedAccount forKey:@"account"];
    }
}

@end
