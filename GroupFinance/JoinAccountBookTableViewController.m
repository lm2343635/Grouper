//
//  JoinAccountBookTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 7/3/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "JoinAccountBookTableViewController.h"
#import "DaoManager.h"
#import "AlertTool.h"

@interface JoinAccountBookTableViewController ()

@end

@implementation JoinAccountBookTableViewController {
    DaoManager *dao;
    NSMutableArray *accountBooks;
    AccountBook *selectedAccountBook;
    NSString *userId;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao=[[DaoManager alloc] init];
    NSError *error = nil;
    NSLog(@"%@", _qrCodeContent);
    NSObject *object = [NSJSONSerialization JSONObjectWithData:[_qrCodeContent dataUsingEncoding:NSUTF8StringEncoding]
                                                       options:NSJSONReadingMutableContainers
                                                         error:&error];
    if(error) {
        if(DEBUG) {
            NSLog(@"Error reading json: %@", error.localizedDescription);
        }
        [AlertTool showAlertWithTitle:@"Tip"
                           andContent:@"Scanning QR code error!"
                     inViewController:self];
    }
    if([[object valueForKey:@"task"] isEqualToString:@"joinAccountBook"]) {
        userId = [object valueForKey:@"userId"];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewWillAppear:animated];
    accountBooks=[NSMutableArray arrayWithArray:[dao.accountBookDao findAllWithEntityName:AccountBookEntityName]];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return accountBooks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    AccountBook *accountBook=[accountBooks objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accountBookIdentifier"
                                                            forIndexPath:indexPath];
    UILabel *abnameLabel=(UILabel *)[cell viewWithTag:1];
    abnameLabel.text=accountBook.abname;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    selectedAccountBook = [accountBooks objectAtIndex:indexPath.row];
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Invite to %@", selectedAccountBook.abname]
                                                                   message:@"Confirm to invite to this account book"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm"
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              
                                                              NSMutableArray *cooperaters = [NSJSONSerialization JSONObjectWithData:[selectedAccountBook.cooperaters dataUsingEncoding:NSUTF8StringEncoding]
                                                                                                                            options:NSJSONReadingMutableContainers
                                                                                                                              error:nil];
                                                              [cooperaters addObject:userId];
                                                              selectedAccountBook.cooperaters = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:cooperaters
                                                                                                                                                               options:NSJSONWritingPrettyPrinted
                                                                                                                                                                 error:nil]
                                                                                                                      encoding:NSUTF8StringEncoding];
                                                              [dao saveContext];
                                                          }];
    [sheet addAction:cancelAction];
    [sheet addAction:confirmAction];
    [self presentViewController:sheet animated:YES completion:nil];
}

@end
