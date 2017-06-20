//
//  SelectRecordItemTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/29/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "SelectRecordItemTableViewController.h"
#import "DaoManager.h"

@interface SelectRecordItemTableViewController ()

@end

@implementation SelectRecordItemTableViewController {
    DaoManager *dao;
    NSArray *items;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao = [DaoManager sharedInstance];

    switch (_selectItemType.unsignedIntegerValue) {
        case SELECT_ITEM_TYPE_CLASSIFICATION:
            items = [dao.classificationDao findAll];
            self.navigationItem.title = @"Select a Classification";
            break;
        case SELECT_ITEM_TYPE_ACCOUNT:
            items = [dao.accountDao findAll];
            self.navigationItem.title = @"Select an Account";
            break;
        case SELECT_ITEM_TYPE_SHOP:
            items = [dao.shopDao findAll];
            self.navigationItem.title = @"Select a Shop";
            break;
        default:
            break;
    }
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return 0.01;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemIdentifier"
                                                            forIndexPath:indexPath];
    UILabel *itemNameLabel = (UILabel *)[cell viewWithTag:1];
    NSObject *item = [items objectAtIndex:indexPath.row];
    switch (_selectItemType.unsignedIntegerValue) {
        case SELECT_ITEM_TYPE_CLASSIFICATION:
            itemNameLabel.text = [item valueForKey:@"cname"];
            break;
        case SELECT_ITEM_TYPE_ACCOUNT:
            itemNameLabel.text = [item valueForKey:@"aname"];
            break;
        case SELECT_ITEM_TYPE_SHOP:
            itemNameLabel.text = [item valueForKey:@"sname"];
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UIViewController *controller = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    [controller setValue:[items objectAtIndex:indexPath.row] forKey:@"item"];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }

}

@end
