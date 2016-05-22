//
//  EditClassificationViewController.h
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DaoManager.h"

@interface EditClassificationViewController : UIViewController

@property (nonatomic, strong) Classification *classification;

@property (weak, nonatomic) IBOutlet UITextField *cnameTextField;

- (IBAction)save:(id)sender;

@end
