//
//  EditAccountBookViewController.h
//  GroupFinance
//
//  Created by lidaye on 5/15/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DaoManager.h"

@interface EditAccountBookViewController : UIViewController

@property (nonatomic, strong) AccountBook *accountBook;

@property (weak, nonatomic) IBOutlet UITextField *accountBookNameTextField;


- (IBAction)saveEidt:(id)sender;
- (IBAction)setAsUsing:(id)sender;

@end
