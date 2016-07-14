//
//  ClassificationsTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "ClassificationsTableViewController.h"
#import "DaoManager.h"

@interface ClassificationsTableViewController ()

@end

@implementation ClassificationsTableViewController {
    DaoManager *dao;
    AccountBook *usingAccountBook;
    NSMutableArray *classifications;
    Classification *selectedClassification;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao=[[DaoManager alloc] init];
    usingAccountBook=[dao.accountBookDao getUsingAccountBook];
}

- (void)viewWillAppear:(BOOL)animated {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    classifications=[NSMutableArray arrayWithArray:[dao.classificationDao findWithAccountBook:usingAccountBook]];
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return classifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Classification *classification=[classifications objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"classificationIndentifer"
                                                                forIndexPath:indexPath];
    UILabel *cnameLabel=(UILabel *)[cell viewWithTag:0];
    cnameLabel.text=classification.cname;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    selectedClassification=[classifications objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"editClassificationSegue" sender:self];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if(editingStyle==UITableViewCellEditingStyleDelete) {
        [dao.syncContext deleteObject:[classifications objectAtIndex:indexPath.row]];
        [dao saveContext];
        [classifications removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if([segue.identifier isEqualToString:@"editClassificationSegue"]) {
        UIViewController *controller=[segue destinationViewController];
        [controller setValue:selectedClassification forKey:@"classification"];
    }
}

@end
