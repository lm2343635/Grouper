//
//  TemplatesTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 6/5/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "TemplatesTableViewController.h"
#import "AddRecordViewController.h"
#import "DaoManager.h"

@interface TemplatesTableViewController ()

@end

@implementation TemplatesTableViewController {
    DaoManager *dao;
    NSMutableArray *templates;
    AccountBook *usingAccountBook;
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
    [super viewWillAppear:animated];
    templates=[NSMutableArray arrayWithArray:[dao.templateDao findWithAccountBook:usingAccountBook]];
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return templates.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Template *template = [templates objectAtIndex:indexPath.row];
    NSString *cellIdentifier = template.saveRecordType.boolValue? @"templateEarnCell": @"templateSpendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    UILabel *templateNameLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *templateInformationLable = (UILabel *)[cell viewWithTag:2];
    templateNameLabel.text = template.tname;
    templateInformationLable.text = [NSString stringWithFormat:@"%@ | %@ | %@", template.classification.cname, template.account.aname, template.shop.sname];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSUInteger viewControllersCount = self.navigationController.viewControllers.count;
    UIViewController *lastController = [self.navigationController.viewControllers objectAtIndex:viewControllersCount-2];
    if([lastController isKindOfClass:AddRecordViewController.class]) {
        [lastController setValue:[templates objectAtIndex:indexPath.row] forKey:@"template"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Template *template = [templates objectAtIndex:indexPath.row];
    if(editingStyle == UITableViewCellEditingStyleDelete && [template isEditableForUser:userId]) {
        [dao.syncContext deleteObject:template];
        [dao saveContext];
        [templates removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
