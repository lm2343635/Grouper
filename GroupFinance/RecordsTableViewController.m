
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

@interface RecordsTableViewController ()

@end

@implementation RecordsTableViewController {
    DaoManager *dao;
    NSMutableArray *records;
    AccountBook *usingAccountBook;
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
    records=[[NSMutableArray alloc] initWithArray:[dao.recordDao findByAccountBook:usingAccountBook]];
    [self.tableView reloadData];
}

#pragma mark - Table view data source
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
    Record *record=[records objectAtIndex:indexPath.row];
    UILabel *dayLabel=(UILabel *)[cell viewWithTag:1];
    UILabel *classificationNameLabel=(UILabel *)[cell viewWithTag:2];
    UILabel *informationLabel=(UILabel *)[cell viewWithTag:3];
    UILabel *moneyLabel=(UILabel *)[cell viewWithTag:4];
    dayLabel.text=[DateTool formateDate:record.time withFormat:DateFormatDay];
    classificationNameLabel.text=record.classification.cname;
    informationLabel.text=[NSString stringWithFormat:@"%@ | %@",record.account.aname,record.shop.sname];
    moneyLabel.text=[NSString stringWithFormat:@"%@",record.money];
    if([record.money doubleValue]<0) {
        moneyLabel.textColor=[UIColor redColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self performSegueWithIdentifier:@"recordSegue" sender:self];
}

@end
