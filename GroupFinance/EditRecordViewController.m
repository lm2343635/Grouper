//
//  EditRecordViewController.m
//  GroupFinance
//
//  Created by lidaye on 6/5/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "EditRecordViewController.h"
#import "SelectRecordItemTableViewController.h"
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

#pragma mark - UITextViewDelegate
-(void)textViewDidBeginEditing:(UITextView *)textView {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class,NSStringFromSelector(_cmd));
    }
    if(textView==_remarkTextView) {
        CGRect frame = textView.frame;
        int offset=frame.origin.y+textView.frame.size.height-(self.view.frame.size.height-KeyboardHeight);
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
        if(offset > 0) {
            self.view.frame=CGRectMake(0.0f,-offset,self.view.frame.size.width,self.view.frame.size.height);
        }
        [UIView commitAnimations];
        _remarkOK.hidden=NO;
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class,NSStringFromSelector(_cmd));
    }
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
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
    UIViewController *controller=[segue destinationViewController];
    if([segue.identifier isEqualToString:@"editRecordItemSegue"]) {
        [controller setValue:[NSNumber numberWithInteger:selectItemType] forKey:@"selectItemType"];
    } else if([segue.identifier isEqualToString:@"showPhotoSegue"]) {
        [controller setValue:[UIImage imageWithData:_record.photo.data] forKey:@"image"];
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
                                                               if(DEBUG) {
                                                                   NSLog(@"iOS Simulator cannot open camera.");
                                                               }
                                                               [AlertTool showAlertWithTitle:@"Warning"
                                                                                  andContent:@"iOS Simulator cannot open camera."
                                                                            inViewController:self];
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
    if(_record.photo) {
        UIAlertAction *showAction=[UIAlertAction actionWithTitle:@"Show"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self performSegueWithIdentifier:@"showPhotoSegue" sender:self];
                                                         }];
        
        [alertController addAction:showAction];
    }
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

- (IBAction)finishEditRemark:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    [_remarkTextView resignFirstResponder];
    _remarkOK.hidden=YES;
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
