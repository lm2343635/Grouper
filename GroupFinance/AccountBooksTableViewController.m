//
//  AccountBooksTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 4/26/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AccountBooksTableViewController.h"
#import "DaoManager.h"

@interface AccountBooksTableViewController ()

@end

@implementation AccountBooksTableViewController {
    DaoManager *dao;
    NSMutableArray *accountBooks;
    AccountBook *selectedAccountBook;
    NSString *usingAccountBookIdentifier;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    dao=[[DaoManager alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewWillAppear:animated];
    //get using account book identifier from sanbox
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    usingAccountBookIdentifier = [defaults objectForKey:@"usingAccountBookIdentifier"];
    //find account books
    accountBooks=[NSMutableArray arrayWithArray:[dao.accountBookDao findAllWithEntityName:AccountBookEntityName]];
    [self.tableView reloadData];
}


#pragma mark - Table view data source
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
    NSString *identifier = [accountBook.uniqueIdentifier isEqualToString:usingAccountBookIdentifier]? @"usingAccountBookIndentifer": @"accountBookIndentifer";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier
                                                            forIndexPath:indexPath];
    UILabel *abnameLabel=(UILabel *)[cell viewWithTag:1];
    abnameLabel.text=accountBook.abname;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    selectedAccountBook=[accountBooks objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"editAccountBookSegue" sender:self];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if(editingStyle==UITableViewCellEditingStyleDelete) {
        [dao.context deleteObject:[accountBooks objectAtIndex:indexPath.row]];
        [dao saveContext];
        [accountBooks removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if([segue.identifier isEqualToString:@"editAccountBookSegue"]) {
        UIViewController *controller=[segue destinationViewController];
        [controller setValue:selectedAccountBook forKey:@"accountBook"];
    }
}

@end
