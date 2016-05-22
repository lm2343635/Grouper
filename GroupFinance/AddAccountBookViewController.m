//
//  AddAccountBookViewController.m
//  GroupFinance
//
//  Created by lidaye on 4/26/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AddAccountBookViewController.h"
#import "AppDelegate.h"
#import "AccountBook.h"

@interface AddAccountBookViewController ()

@end

@implementation AddAccountBookViewController {
    NSManagedObjectContext *context;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AppDelegate *delegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    context=delegate.managedObjectContext;
}

- (IBAction)save:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [AccountBook saveWithName:_abnameTextField.text
        inMangedObjectContext:context];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
