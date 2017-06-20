//
//  SynchronizationTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/8/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "SynchronizationTableViewController.h"

@interface SynchronizationTableViewController ()

@end

@implementation SynchronizationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)synchronize:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }

}
@end
