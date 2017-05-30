//
//  LoginViewController.h
//  GroupFinance
//
//  Created by lidaye on 6/12/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

- (IBAction)setUserInfo:(id)sender;

@end
