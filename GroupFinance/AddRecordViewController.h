//
//  AddRecordViewController.h
//  GroupFinance
//
//  Created by lidaye on 5/29/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DaoManager.h"
#import "DateSelectorView.h"

#define TakePhotoActionSheetCameraIndex 0
#define TakePhotoActionSheetPhtotLibraryIndex 1

#define SELECT_ITEM_TYPE_CLASSIFICATION 1
#define SELECT_ITEM_TYPE_ACCOUNT 2
#define SELECT_ITEM_TYPE_SHOP 3

@interface AddRecordViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSObject *item;
@property (strong, nonatomic) Classification *selectedClassification;
@property (strong, nonatomic) Account *selectedAccount;
@property (strong, nonatomic) Shop *selectedShop;
@property (strong, nonatomic) NSDate *selectedTime;
@property (strong, nonatomic) UIImage *photoImage;

@property (weak, nonatomic) IBOutlet DateSelectorView *timeSelectorView;

@property (weak, nonatomic) IBOutlet UILabel *saveTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UITextField *moneyTextFeild;
@property (weak, nonatomic) IBOutlet UISwitch *saveTypeSwitch;
@property (weak, nonatomic) IBOutlet UIButton *selectClassificationButton;
@property (weak, nonatomic) IBOutlet UIButton *selectAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *selectShopButton;
@property (weak, nonatomic) IBOutlet UIButton *selectTimeButton;
@property (weak, nonatomic) IBOutlet UITextView *remarkTextView;

- (IBAction)save:(id)sender;
- (IBAction)selectClassification:(id)sender;
- (IBAction)selectAccount:(id)sender;
- (IBAction)selectShop:(id)sender;
- (IBAction)selectTime:(id)sender;
- (IBAction)takePhoto:(id)sender;
- (IBAction)changeSaveType:(id)sender;

@end