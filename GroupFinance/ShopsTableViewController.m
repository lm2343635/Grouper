//
//  ShopsTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "ShopsTableViewController.h"
#import "DaoManager.h"

@interface ShopsTableViewController ()

@end

@implementation ShopsTableViewController {
    DaoManager *dao;
    AccountBook *usingAccountBook;
    NSMutableArray *shops;
    Shop *selectedShop;
    NSString *userId;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao = [[DaoManager alloc] init];
    usingAccountBook = [dao.accountBookDao getUsingAccountBook];
    userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
}

- (void)viewWillAppear:(BOOL)animated {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    shops = [NSMutableArray arrayWithArray:[dao.shopDao findWithAccountBook:usingAccountBook]];
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return shops.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Shop *shop = [shops objectAtIndex:indexPath.row];
    NSString *identifier = [shop isEditableForUser:userId]? @"shopIndentifer": @"cooperateShopIndentifer";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    UILabel *snameLabel = (UILabel *)[cell viewWithTag:1];
    snameLabel.text = shop.sname;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    selectedShop = [shops objectAtIndex:indexPath.row];
    if([selectedShop isEditableForUser:userId]) {
        [self performSegueWithIdentifier:@"editShopSegue" sender:self];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Shop *shop = [shops objectAtIndex:indexPath.row];
    if(editingStyle == UITableViewCellEditingStyleDelete && [shop isEditableForUser:userId]) {
        [dao.syncContext deleteObject:[shops objectAtIndex:indexPath.row]];
        [dao saveContext];
        [shops removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if([segue.identifier isEqualToString:@"editShopSegue"]) {
        UIViewController *controller=[segue destinationViewController];
        [controller setValue:selectedShop forKey:@"shop"];
    }
}

@end