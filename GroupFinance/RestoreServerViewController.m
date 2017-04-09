//
//  RestoreServerViewController.m
//  GroupFinance
//
//  Created by lidaye on 26/12/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "RestoreServerViewController.h"
#import "GroupManager.h"
#import "DaoManager.h"
#import "NetManager.h"
#import "AlertTool.h"

@interface RestoreServerViewController ()

@end

@implementation RestoreServerViewController {
    NetManager *net;
    GroupManager *group;
    DaoManager *dao;
    User *currentUser;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    net = [NetManager sharedInstance];
    group = [GroupManager sharedInstance];
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
    for (NSString *address in group.defaults.servers.allKeys) {
        if ([_addressTextField.text isEqualToString:address]) {
            [AlertTool showAlertWithTitle:@"Tip"
                               andContent:@"This server is exist!"
                         inViewController:self];
            return;
        }
    }

    [net.manager POST:[NSString stringWithFormat:@"http://%@/group/restore", _addressTextField.text]
       parameters:@{
                    @"uid": currentUser.userId,
                    @"accesskey": _accessKeyTextField.text
                    }
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
              if ([response statusOK]) {
                  NSObject *result = [response getResponseResult];
                  [group.defaults addServerAddress:_addressTextField.text
                                     withAccessKey:_accessKeyTextField.text];
                  //Restore group info.
                  if (group.defaults.initial == NotInitial) {
                      NSObject *groupInfo = [result valueForKey:@"group"];
                      group.defaults.groupId = [groupInfo valueForKey:@"id"];
                      group.defaults.groupName = [groupInfo valueForKey:@"name"];
                      group.defaults.members = [[groupInfo valueForKey:@"members"] integerValue];
                      group.defaults.owner = [groupInfo valueForKey:@"oid"];
                      group.defaults.serverCount = [[groupInfo valueForKey:@"servers"] integerValue];
                      group.defaults.threshold = [[groupInfo valueForKey:@"threshold"] integerValue];
                      group.defaults.initial = RestoringServer;
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
