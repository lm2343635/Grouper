//
//  LoginViewController.m
//  GroupFinance
//
//  Created by lidaye on 6/12/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "LoginViewController.h"
#import "DaoManager.h"

@interface LoginViewController ()

@end

@implementation LoginViewController {
    DaoManager *dao;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    
    _loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
}

#pragma mark - FBSDKLoginButtonDelegate
- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if(error) {
        NSLog(@"Login failed with error: %@", error.localizedDescription);
    }
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:result.token.tokenString forKey:@"token"];
    [defaults setObject:result.token.userID forKey:@"userId"];
    dao=[[DaoManager alloc] init];
    [dao.userDao saveWithToken:result.token.tokenString
                        andUid:result.token.userID];
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:result.token.userID
                                                                   parameters:@{@"fields": @"picture, email, name, gender"}
                                                                   HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if(DEBUG) {
            NSLog(@"Get facebook user info: %@", result);
        }
        [defaults setObject:result forKey:@"user"];
    }];
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}
@end
