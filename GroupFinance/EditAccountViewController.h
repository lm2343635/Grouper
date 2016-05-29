//
//  EditAccountViewController.h
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DaoManager.h"

@interface EditAccountViewController : UIViewController

@property (nonatomic, strong) Account *account;

@property (weak, nonatomic) IBOutlet UITextField *anameTextField;

- (IBAction)save:(id)sender;

@end
