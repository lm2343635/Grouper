//
//  RestoreServerViewController.m
//  GroupFinance
//
//  Created by lidaye on 26/12/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "RestoreServerViewController.h"
#import "AlertTool.h"
#import "InternetTool.h"
#import "GroupTool.h"
#import "DaoManager.h"

@interface RestoreServerViewController ()

@end

@implementation RestoreServerViewController {
    AFHTTPSessionManager *manager;
    GroupTool *group;
    DaoManager *dao;
    User *currentUser;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    manager = [InternetTool getSessionManager];
    group = [GroupTool sharedInstance];
    dao = [DaoManager sharedInstance];
    currentUser = [dao.userDao currentUser];
}

#pragma mark - Action
- (IBAction)restore:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([_addressTextField.text isEqualToString:@""]
        || [_accessKeyTextField.text isEqualToString:@""]) {
        [AlertTool showAlertWithTitle:@"Tip"
                           andContent:@"Server address and access key cannot be empty!"
                     inViewController:self];
        return;
    }
    for (NSString *address in group.servers.allKeys) {
        if ([_addressTextField.text isEqualToString:address]) {
            [AlertTool showAlertWithTitle:@"Tip"
                               andContent:@"This server is exist!"
                         inViewController:self];
            return;
        }
    }

    [manager POST:[NSString stringWithFormat:@"http://%@/group/restore", _addressTextField.text]
       parameters:@{
                    @"uid": currentUser.uid,
                    @"accesskey": _accessKeyTextField.text
                    }
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
              if ([response statusOK]) {
                  NSObject *result = [response getResponseResult];
                  [group addServerAddress:_addressTextField.text
                            withAccessKey:_accessKeyTextField.text];
                  //Restore group info.
                  if (group.initial == NotInitial) {
                      NSObject *groupInfo = [result valueForKey:@"group"];
                      group.groupId = [groupInfo valueForKey:@"id"];
                      group.groupName = [groupInfo valueForKey:@"name"];
                      group.members = [[groupInfo valueForKey:@"members"] integerValue];
                      group.owner = [groupInfo valueForKey:@"oid"];
                      group.serverCount = [[groupInfo valueForKey:@"servers"] integerValue];
                      group.threshold = [[groupInfo valueForKey:@"threshold"] integerValue];
                      group.initial = RestoringServer;
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
                  case ErrorAccessKey:
                      [AlertTool showAlertWithTitle:@"Tip"
                                         andContent:@"Access key is not found in this server."
                                   inViewController:self];
                      break;
                  case ErrorUserNotInGroup:
                      [AlertTool showAlertWithTitle:@"Tip"
                                         andContent:@"This user is not in the group with this access key."
                                   inViewController:self];
                      break;
                  default:
                      break;
              }
          }];
}
@end
