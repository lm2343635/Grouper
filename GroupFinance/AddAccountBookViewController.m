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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)save:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [AccountBook saveWithName:_abnameTextField.text
        inMangedObjectContext:context];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
