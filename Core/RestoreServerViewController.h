//
//  RestoreServerViewController.h
//  GroupFinance
//
//  Created by lidaye on 26/12/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RestoreServerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *accessKeyTextField;

- (IBAction)restore:(id)sender;

@end
