//
//  SelectRecordItemTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/29/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "SelectRecordItemTableViewController.h"
#import "AddRecordViewController.h"


@interface SelectRecordItemTableViewController ()

@end

@implementation SelectRecordItemTableViewController {
    DaoManager *dao;
    NSArray *items;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao=[[DaoManager alloc] init];
    AccountBook *usingAccountBook=[dao.accountBookDao getUsingAccountBook];
    switch (_selectItemType.unsignedIntegerValue) {
        case SELECT_ITEM_TYPE_CLASSIFICATION:
            items=[dao.classificationDao findWithAccountBook:usingAccountBook];
            self.navigationItem.title=@"Select a Classification";
            break;
        case SELECT_ITEM_TYPE_ACCOUNT:
            items=[dao.accountDao findWithAccountBook:usingAccountBook];
            self.navigationItem.title=@"Select an Account";
            break;
        case SELECT_ITEM_TYPE_SHOP:
            items=[dao.shopDao findWithAccountBook:usingAccountBook];
            self.navigationItem.title=@"Select a Shop";
            break;
        default:
            break;
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemIdentifier"
                                                            forIndexPath:indexPath];
    UILabel *itemNameLabel=(UILabel *)[cell viewWithTag:0];
    NSObject *item=[items objectAtIndex:indexPath.row];
    switch (_selectItemType.unsignedIntegerValue) {
        case SELECT_ITEM_TYPE_CLASSIFICATION:
            itemNameLabel.text=[item valueForKey:@"cname"];
            break;
        case SELECT_ITEM_TYPE_ACCOUNT:
            itemNameLabel.text=[item valueForKey:@"aname"];
            break;
        case SELECT_ITEM_TYPE_SHOP:
            itemNameLabel.text=[item valueForKey:@"sname"];
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    AddRecordViewController *controller=[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    controller.item=[items objectAtIndex:indexPath.row];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }

}

@end
