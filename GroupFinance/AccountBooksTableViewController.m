//
//  AccountBooksTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 4/26/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AccountBooksTableViewController.h"
#import "EditAccountBookViewController.h"
#import "AppDelegate.h"
#import "AccountBook.h"

@interface AccountBooksTableViewController ()

@end

@implementation AccountBooksTableViewController {
    AppDelegate *delegate;
    NSMutableArray *accountBooks;
    AccountBook *selectedAccountBook;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    delegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];}

- (void)viewWillAppear:(BOOL)animated {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewWillAppear:animated];
    accountBooks=[NSMutableArray arrayWithArray:[AccountBook findAllinMangedObjectContext:delegate.managedObjectContext]];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accountBookCellIndentifer"
                                                            forIndexPath:indexPath];
    
    UILabel *abnameLabel=(UILabel *)[cell viewWithTag:0];
    AccountBook *accountBook=[accountBooks objectAtIndex:indexPath.row];
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
        [delegate.managedObjectContext deleteObject:[accountBooks objectAtIndex:indexPath.row]];
        [delegate.managedObjectContext save:nil];
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
        EditAccountBookViewController *controller=(UIVideoEditorController *)[segue destinationViewController];
        controller.accountBook=selectedAccountBook;
    }
}

@end
