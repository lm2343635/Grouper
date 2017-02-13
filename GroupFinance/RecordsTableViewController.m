
//
//  RecordsTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/29/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "RecordsTableViewController.h"
#import "DaoManager.h"
#import "DateTool.h"
#import "SendManager.h"

@interface RecordsTableViewController ()

@end

@implementation RecordsTableViewController {
    DaoManager *dao;
    NSMutableArray *records;
    Record *selectedRecord;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao = [DaoManager sharedInstance];
}

- (void)viewWillAppear:(BOOL)animated {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    records = [[NSMutableArray alloc] initWithArray:[dao.recordDao findAll]];
    [self.tableView reloadData];
}

#pragma mark - Table view data source
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
    return records.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recordIdentifier" forIndexPath:indexPath];
    Record *record = [records objectAtIndex:indexPath.row];
    UILabel *dayLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *classificationNameLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *informationLabel = (UILabel *)[cell viewWithTag:3];
    UILabel *moneyLabel = (UILabel *)[cell viewWithTag:4];
    dayLabel.text = [DateTool formateDate:record.time withFormat:DateFormatDay];
    classificationNameLabel.text = record.classification.cname;
    informationLabel.text = [NSString stringWithFormat:@"%@ | %@",record.account.aname,record.shop.sname];
    moneyLabel.text = [NSString stringWithFormat:@"%@",record.money];
    if([record.money doubleValue] < 0) {
        moneyLabel.textColor=[UIColor redColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    selectedRecord = [records objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"recordSegue" sender:self];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Record *record = [records objectAtIndex:indexPath.row];
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        [[SendManager sharedInstance] delete:record];
        [records removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:YES];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if([segue.identifier isEqualToString:@"recordSegue"]) {
        UIViewController *controller = [segue destinationViewController];
        [controller setValue:selectedRecord forKey:@"record"];
    }
}

@end
