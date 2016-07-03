//
//  ScanQRCodeViewController.h
//  GroupFinance
//
//  Created by lidaye on 7/2/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@import AVFoundation;

@interface ScanQRCodeViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) CGRect scanRect;
@property (nonatomic, assign) BOOL isQRCodeCaptured;

- (IBAction)pickFromPhotos:(id)sender;

@end
