//
//  AddTemplateViewController.h
//  GroupFinance
//
//  Created by lidaye on 6/5/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DaoManager.h"

@interface AddTemplateViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) NSObject *item;
@property (strong, nonatomic) NSNumber *recordType;
@property (strong, nonatomic) Classification *selectedClassification;
@property (strong, nonatomic) Account *selectedAccount;
@property (strong, nonatomic) Shop *selectedShop;

@property (weak, nonatomic) IBOutlet UITextField *templateNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *saveTypeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *saveTypeSwitch;
@property (weak, nonatomic) IBOutlet UIButton *selectClassificationButton;
@property (weak, nonatomic) IBOutlet UIButton *selectAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *selectShopButton;

- (IBAction)save:(id)sender;
- (IBAction)selectClassification:(id)sender;
- (IBAction)selectAccount:(id)sender;
- (IBAction)selectShop:(id)sender;
- (IBAction)changeSaveType:(id)sender;

@end
