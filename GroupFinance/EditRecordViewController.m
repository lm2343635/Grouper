//
//  EditRecordViewController.m
//  GroupFinance
//
//  Created by lidaye on 6/5/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "EditRecordViewController.h"
#import "DaoManager.h"
#import "AlertTool.h"
#import "DateTool.h"

@interface EditRecordViewController ()

@end

@implementation EditRecordViewController {
    DaoManager *dao;
    NSUInteger selectItemType;
    UIImagePickerController *imagePickerController;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao=[[DaoManager alloc] init];
    imagePickerController=[[UIImagePickerController alloc] init];
    imagePickerController.delegate=self;
    if(_record.photo!=nil) {
        [_takePhotoButton setImage:[UIImage imageWithData:_record.photo.data]
                          forState:UIControlStateNormal];
    }
    [_moneyTextFeild setText:[NSString stringWithFormat:@"%@", _record.money]];
    [_saveTypeSwitch setOn:_record.money.intValue>=0];
    [_saveTypeLabel setText:_record.money.intValue>=0? @"Save as Earn": @"Save as Spend"];
    [_selectClassificationButton setTitle:_record.classification.cname
                                 forState:UIControlStateNormal];
    [_selectAccountButton setTitle:_record.account.aname
                          forState:UIControlStateNormal];
    [_selectShopButton setTitle:_record.shop.sname
                       forState:UIControlStateNormal];
    [_selectTimeButton setTitle:[DateTool formateDate:_record.time withFormat:DateFormatYearMonthDayHourMinutes]
                       forState:UIControlStateNormal];
    [_remarkTextView setText:_record.remark];
    
}

- (void)viewWillAppear:(BOOL)animated {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if(_item==nil) {
        return;
    }
    switch (selectItemType) {
        case SELECT_ITEM_TYPE_CLASSIFICATION:
            _selectedClassification=(Classification *)_item;
            [_selectClassificationButton setTitle:_selectedClassification.cname
                                         forState:UIControlStateNormal];
            break;
        case SELECT_ITEM_TYPE_ACCOUNT:
            _selectedAccount=(Account *)_item;
            [_selectAccountButton setTitle:_selectedAccount.aname
                                  forState:UIControlStateNormal];
            break;
        case SELECT_ITEM_TYPE_SHOP:
            _selectedShop=(Shop *)_item;
            [_selectShopButton setTitle:_selectedShop.sname
                               forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
        NSLog(@"MediaInfo: %@",info);
    }
    // 获取用户拍摄的是照片还是视频
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    // 判断获取类型：图片
    if([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        _photoImage=[info objectForKey:UIImagePickerControllerEditedImage];
        [_takePhotoButton setImage:_photoImage forState:UIControlStateNormal];
    }
    // 隐藏UIImagePickerController
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if([segue.identifier isEqualToString:@"editRecordItemSegue"]) {
        UIViewController *controller=[segue destinationViewController];
        [controller setValue:[NSNumber numberWithInteger:selectItemType] forKey:@"selectItemType"];
    }
}

#pragma mark - Action
-(void)save:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if(_photoImage) {
        if(_record.photo==nil) {
            NSManagedObjectID *pid=[dao.photoDao saveWithData:UIImageJPEGRepresentation(_photoImage, 1.0)
                                                inAccountBook:[dao.accountBookDao getUsingAccountBook]];
            _record.photo=(Photo *)[dao getObjectById:pid];
        } else {
            _record.photo.data=UIImageJPEGRepresentation(_photoImage, 1.0);
        }
    }
    if(![_remarkTextView.text isEqualToString:@""]) {
        _record.remark=_remarkTextView.text;
    }
    _record.money=[NSNumber numberWithInt:_moneyTextFeild.text.intValue];
    if(_selectedClassification) {
        _record.classification=_selectedClassification;
    }
    if(_selectedAccount) {
        _record.account=_selectedAccount;
    }
    if(_selectedShop) {
        _record.shop=_selectedShop;
    }
    if(_selectedTime) {
        _record.time=_selectedTime;
    }
    [dao saveContext];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)selectClassification:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    _item=nil;
    selectItemType=SELECT_ITEM_TYPE_CLASSIFICATION;
    [self performSegueWithIdentifier:@"editRecordItemSegue" sender:self];
}

- (IBAction)selectAccount:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    _item=nil;
    selectItemType=SELECT_ITEM_TYPE_ACCOUNT;
    [self performSegueWithIdentifier:@"editRecordItemSegue" sender:self];
}

- (IBAction)selectShop:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    _item=nil;
    selectItemType=SELECT_ITEM_TYPE_SHOP;
    [self performSegueWithIdentifier:@"editRecordItemSegue" sender:self];
}

- (IBAction)selectTime:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    _selectTimeButton.enabled=NO;
    [_timeSelectorView initWithCallback:^(NSObject *object) {
        [self setTime:(NSDate *)object];
    }];
}


- (IBAction)takePhoto:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"Choose Photo from"
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];
    UIAlertAction *cameraAction=[UIAlertAction actionWithTitle:@"Camera"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                                               // 将sourceType设为UIImagePickerControllerSourceTypeCamera代表拍照或拍视频
                                                               imagePickerController.sourceType=UIImagePickerControllerSourceTypeCamera;
                                                               // 设置模式为拍摄照片
                                                               imagePickerController.cameraCaptureMode=UIImagePickerControllerCameraCaptureModePhoto;
                                                               // 设置使用手机的后置摄像头（默认使用后置摄像头）
                                                               imagePickerController.cameraDevice=UIImagePickerControllerCameraDeviceRear;
                                                               // 设置拍摄的照片允许编辑
                                                               imagePickerController.allowsEditing=YES;
                                                           }else{
                                                               NSLog(@"iOS Simulator cannot open camera.");
                                                               [AlertTool showAlert:@"iOS Simulator cannot open camera."];
                                                           }
                                                           // 显示picker视图控制器
                                                           [self presentViewController:imagePickerController animated: YES completion:nil];
                                                       }];
    UIAlertAction *libraryAction=[UIAlertAction actionWithTitle:@"Photo Library"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            // 设置选择载相册的图片
                                                            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                            imagePickerController.allowsEditing = YES;
                                                            // 显示picker视图控制器
                                                            [self presentViewController:imagePickerController animated: YES completion:nil];
                                                        }];
    [alertController addAction:cancelAction];
    [alertController addAction:cameraAction];
    [alertController addAction:libraryAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)changeSaveType:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    if([sender isOn]) {
        _record.money=[NSNumber numberWithInt:abs(_record.money.intValue)];
        _saveTypeLabel.text=@"Save as Earn";
    } else {
        _record.money=[NSNumber numberWithInt:-abs(_record.money.intValue)];
        _saveTypeLabel.text=@"Save as Spend";
    }
    [_moneyTextFeild setText:[NSString stringWithFormat:@"%@", _record.money]];
}

#pragma mark - Service
-(void)setTime:(NSDate *)time {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    _selectedTime=time;
    _selectTimeButton.enabled=YES;
    [_selectTimeButton setTitle:[DateTool formateDate:_selectedTime withFormat:DateFormatYearMonthDayHourMinutes]
                       forState:UIControlStateNormal];
}

@end
