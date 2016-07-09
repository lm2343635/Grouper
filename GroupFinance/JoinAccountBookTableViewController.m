//
//  JoinAccountBookTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 7/3/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "JoinAccountBookTableViewController.h"
#import "AlertTool.h"

@interface JoinAccountBookTableViewController ()

@end

@implementation JoinAccountBookTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSError *error = nil;
    NSObject *object = [NSJSONSerialization JSONObjectWithData:[_qrCodeContent dataUsingEncoding:NSUTF8StringEncoding]
                                                       options:NSJSONReadingMutableContainers
                                                         error:&error];
    if(error) {
        if(DEBUG) {
            NSLog(@"Error reading json: %@", error.localizedDescription);
        }
        [AlertTool showAlert:@"Scanning QR code error!"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
