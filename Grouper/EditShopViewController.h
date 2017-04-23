//
//  EditShopViewController.h
//  GroupFinance
//
//  Created by lidaye on 5/22/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DaoManager.h"

@interface EditShopViewController : UIViewController

@property (nonatomic, strong) Shop *shop;

@property (weak, nonatomic) IBOutlet UITextField *snameTextField;

- (IBAction)save:(id)sender;

@end
