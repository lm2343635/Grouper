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
    defaults = [NSUserDefaults standardUserDefaults];
    dao = [[DaoManager alloc] init];
    //Set Facebook Oauth permission.
    _loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
}

- (void)viewDidAppear:(BOOL)animated {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidAppear:animated];
    if ([defaults objectForKey:@"uid"] != nil) {
        [self performSegueWithIdentifier:@"loginSuccessSegue" sender:self];
    }
}

#pragma mark - FBSDKLoginButtonDelegate
- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (error) {
        NSLog(@"Login failed with error: %@", error.localizedDescription);
    }
    
    [defaults setObject:result.token.tokenString forKey:@"token"];
    [defaults setObject:result.token.userID forKey:@"uid"];

    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:result.token.userID
                                                                   parameters:@{@"fields": @"picture, email, name, gender"}
                                                                   HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (DEBUG) {
            NSLog(@"Get facebook user info: %@", result);
        }
        //Save user info from facebook.
        [dao.userDao saveOrUpdateWithJSONObject:result];
        [self performSegueWithIdentifier:@"loginSuccessSegue" sender:self];
    }];
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}
@end
