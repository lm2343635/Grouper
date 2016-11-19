//
//  AddServerViewController.h
//  GroupFinance
//
//  Created by lidaye on 19/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddServerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *groupIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *groupNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *serverAddressTextField;

- (IBAction)submit:(id)sender;

@end
