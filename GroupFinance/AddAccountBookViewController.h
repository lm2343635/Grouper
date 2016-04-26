//
//  AddAccountBookViewController.h
//  GroupFinance
//
//  Created by lidaye on 4/26/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddAccountBookViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *abnameTextField;

- (IBAction)save:(id)sender;

@end
