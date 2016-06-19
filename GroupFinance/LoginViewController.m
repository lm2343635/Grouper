//
//  LoginViewController.m
//  GroupFinance
//
//  Created by lidaye on 6/12/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];

    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    // Optional: Place the button in the center of your view.
    loginButton.center=self.view.center;
    loginButton.delegate=self;
    [self.view addSubview:loginButton];
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
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}
@end
