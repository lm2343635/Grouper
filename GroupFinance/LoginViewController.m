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
    NSUserDefaults *defaults;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    defaults=[NSUserDefaults standardUserDefaults];
    
    
    _loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
}

- (void)viewDidAppear:(BOOL)animated {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidAppear:animated];
    if([defaults boolForKey:@"login"]) {
        [self performSegueWithIdentifier:@"loginSuccessSegue" sender:self];
    }
}

#pragma mark - FBSDKLoginButtonDelegate
- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if(error) {
        NSLog(@"Login failed with error: %@", error.localizedDescription);
    }
    
    [defaults setBool:YES forKey:@"login"];
    [defaults setObject:result.token.tokenString forKey:@"token"];
    [defaults setObject:result.token.userID forKey:@"userId"];

    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:result.token.userID
                                                                   parameters:@{@"fields": @"picture, email, name, gender"}
                                                                   HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if(DEBUG) {
            NSLog(@"Get facebook user info: %@", result);
        }
        dao = [[DaoManager alloc] init];
        [dao.userDao saveWithJSONObject:result];
        [self performSegueWithIdentifier:@"loginSuccessSegue" sender:self];
    }];
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}
@end
