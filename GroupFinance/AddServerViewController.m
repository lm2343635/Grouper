//
//  AddServerViewController.m
//  GroupFinance
//
//  Created by lidaye on 19/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AddServerViewController.h"
#import "GroupManager.h"
#import "AlertTool.h"
#import "InternetTool.h"

@interface AddServerViewController ()

@end

@implementation AddServerViewController {
    AFHTTPSessionManager *manager;
    GroupManager *group;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    manager = [InternetTool getSessionManager];
    group = [GroupManager sharedInstance];
    //If group id and group name has been set, autofill them and disable editing.
    if (group.defaults.groupId != nil && group.defaults.groupName != nil) {
        _groupIdTextField.text = group.defaults.groupId;
        _groupNameTextField.text = group.defaults.groupName;
        _groupIdTextField.enabled = NO;
        _groupNameTextField.enabled = NO;
    }
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
        return;
    }
    for (NSString *address in group.defaults.servers.allKeys) {
        if ([_serverAddressTextField.text isEqualToString:address]) {
            [AlertTool showAlertWithTitle:@"Tip"
                               andContent:@"This server is exist!"
                         inViewController:self];
            return;
        }
    }
    [manager POST:[NSString stringWithFormat:@"http://%@/group/register", _serverAddressTextField.text]
       parameters:@{
                    @"id": _groupIdTextField.text,
                    @"name": _groupNameTextField.text
                    }
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
              if ([response statusOK]) {
                  NSObject *result = [response getResponseResult];
                  [group.defaults addServerAddress:_serverAddressTextField.text
                                     withAccessKey:[result valueForKey:@"masterkey"]];
                  //Set group id and group name.
                  if (group.defaults.initial == NotInitial) {
                      group.defaults.groupId = _groupIdTextField.text;
                      group.defaults.groupName = _groupNameTextField.text;
                      group.defaults.initial = AddingNewServer;
                  }
                  [self.navigationController popViewControllerAnimated:YES];
              }
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              InternetResponse *response = [[InternetResponse alloc] initWithError:error];
              switch ([response errorCode]) {
                  case ErrorNotConnectedToInternet:
                      [AlertTool showAlertWithTitle:@"Tip"
                                         andContent:@"Cannot find this server!"
                                   inViewController:self];
                      break;
                  case ErrorGroupExsit:
                      [AlertTool showAlertWithTitle:@"Tip"
                                         andContent:@"Group id has been registered by other users in this server!"
                                   inViewController:self];
                      break;
                  case ErrorGroupRegister:
                      [AlertTool showAlertWithTitle:@"Tip"
                                         andContent:@"Register group error, try again later."
                                   inViewController:self];
                      break;
                  default:
                      break;
              }
          }];
}
@end
