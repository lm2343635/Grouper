//
//  AddServerViewController.m
//  GroupFinance
//
//  Created by lidaye on 19/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AddServerViewController.h"
#import "AlertTool.h"
#import "InternetTool.h"

@interface AddServerViewController ()

@end

@implementation AddServerViewController {
    AFHTTPSessionManager *manager;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    manager = [InternetTool getSessionManager];
}

- (IBAction)submit:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([_groupIdTextField.text isEqualToString:@""]
        || [_groupNameTextField.text isEqualToString:@""]
        || [_serverAddressTextField.text isEqualToString:@""]) {
        [AlertTool showAlertWithTitle:@"Tip"
                           andContent:@"Group id, group name and server address cannot be empty!"
                     inViewController:self];
    }
    [manager POST:[NSString stringWithFormat:@"http://%@/group/register", _serverAddressTextField.text]
       parameters:@{
                    @"id": _groupIdTextField.text,
                    @"name": _groupNameTextField.text
                    }
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
              NSLog(@"%@", [response.data valueForKey:@"masterKey"]);
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              
          }];
}
@end
