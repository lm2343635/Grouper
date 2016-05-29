//
//  AddRecordViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/29/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "AddRecordViewController.h"
#import "DaoManager.h"
#import "AlertTool.h"


@interface AddRecordViewController ()

@end

@implementation AddRecordViewController {
    DaoManager *dao;
    NSUInteger selectItemType;
    UIImagePickerController *imagePickerController;
    BOOL saveRecordType;
    AccountBook *usingAccountBook;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao=[[DaoManager alloc] init];
    usingAccountBook=[dao.accountBookDao getUsingAccountBook];
    imagePickerController=[[UIImagePickerController alloc] init];
    imagePickerController.delegate=self;
    saveRecordType=NO;
    [self setTime:[[NSDate alloc] init]];
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

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
        NSLog(@"Click at index %d", buttonIndex);
    }
    switch (buttonIndex) {
        case TakePhotoActionSheetCameraIndex:
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
            
            break;
        case TakePhotoActionSheetPhtotLibraryIndex:
            // 设置选择载相册的图片
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePickerController.allowsEditing = YES;
            break;
        default:
            
            break;
    }
    // 显示picker视图控制器
    [self presentViewController:imagePickerController animated: YES completion:nil];
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
        self.photoImage=[info objectForKey:UIImagePickerControllerEditedImage];
        [self.takePhotoButton setImage:self.photoImage forState:UIControlStateNormal];
    }
    // 隐藏UIImagePickerController
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if([segue.identifier isEqualToString:@"selectRecordItemSegue"]) {
        UIViewController *controller=[segue destinationViewController];
        [controller setValue:[NSNumber numberWithInteger:selectItemType] forKey:@"selectItemType"];
    }
}

#pragma mark - Action
- (IBAction)save:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if(_selectedAccount==nil||
       _selectedClassification==nil||
       _selectedShop==nil||
       [_moneyTextFeild.text isEqualToString:@""]) {
        [AlertTool showAlert:@"Please select classification, account and shop before you save the record."];
        return;
    }
    int moneyInt=(int)_moneyTextFeild.text.doubleValue;
    NSNumber *money=[NSNumber numberWithInt: saveRecordType==YES ? moneyInt: -moneyInt];
    Photo *photo=nil;
    //如果用户拍过照就要新建Photo对象
    if(_photoImage!=nil) {
        NSManagedObjectID *pid=[dao.photoDao saveWithData:UIImageJPEGRepresentation(_photoImage, 1.0)
                                            inAccountBook:usingAccountBook];
        if(DEBUG) {
            NSLog(@"Create photo(pid=%@) in accountBook %@", pid, usingAccountBook.abname);
        }
        photo=(Photo *)[dao getObjectById:pid];
    }
    
    NSManagedObjectID *rid=[dao.recordDao saveWithMoney:money
                                              andRemark:_remarkTextView.text
                                                andTime:_selectedTime
                                      andClassification:_selectedClassification
                                             andAccount:_selectedAccount
                                                andShop:_selectedShop
                                               andPhoto:photo
                                          inAccountBook:usingAccountBook];
    if(DEBUG) {
        NSLog(@"Create record(rid=%@) in accountBook %@", rid, usingAccountBook.abname);
    }
    if(rid) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)selectClassification:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    _item=nil;
    selectItemType=SELECT_ITEM_TYPE_CLASSIFICATION;
    [self performSegueWithIdentifier:@"selectRecordItemSegue" sender:self];
}

- (IBAction)selectAccount:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    _item=nil;
    selectItemType=SELECT_ITEM_TYPE_ACCOUNT;
    [self performSegueWithIdentifier:@"selectRecordItemSegue" sender:self];
}

- (IBAction)selectShop:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    _item=nil;
    selectItemType=SELECT_ITEM_TYPE_SHOP;
    [self performSegueWithIdentifier:@"selectRecordItemSegue" sender:self];
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
    UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:@"Choose photo from"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:@"Camera",@"Photo Library", nil];
    [sheet showInView:self.view];
}

- (IBAction)changeSaveType:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if([sender isOn]) {
        _saveTypeLabel.text=@"Save as Earn";
        
    } else {
        _saveTypeLabel.text=@"Save as Spend";
       
    }
}

#pragma mark - Service
-(void)setTime:(NSDate *)time {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    _selectedTime=time;
    // 创建一个日期格式器
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // 为日期格式器设置格式字符串
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *timeString = [dateFormatter stringFromDate:self.selectedTime];
    _selectTimeButton.enabled=YES;
    [_selectTimeButton setTitle:timeString
                       forState:UIControlStateNormal];
}

@end
