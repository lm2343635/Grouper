//
//  ScanQRCodeViewController.m
//  GroupFinance
//
//  Created by lidaye on 7/2/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "ScanQRCodeViewController.h"
#import "QRScanView.h"

@interface ScanQRCodeViewController ()

@end

@implementation ScanQRCodeViewController {
    NSString *qrCodeContent;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    [self setup];
}

#pragma mark - Action
- (IBAction)pickFromPhotos:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if([segue.identifier isEqualToString:@"jionAccountBookSegue"]) {
        [segue.destinationViewController setValue:qrCodeContent forKey:@"qrCodeContent"];
    }
}

#pragma mark - Setup
- (void)setup {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authorizationStatus) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler: ^(BOOL granted) {
                if (granted) {
                    [self setupCapture];
                } else {
                    NSLog(@"%@", @"访问受限");
                }
            }];
            break;
        }
            
        case AVAuthorizationStatusAuthorized: {
            [self setupCapture];
            break;
        }
            
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied: {
            NSLog(@"%@", @"访问受限");
            break;
        }
            
        default: {
            break;
        }
    }
    
    self.scanRect = CGRectMake(60.0f, 100.0f, 200.0f, 200.0f);
}

- (void)setupCapture {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        AVCaptureSession *session = [[AVCaptureSession alloc] init];
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        NSError *error;
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (deviceInput) {
            [session addInput:deviceInput];
            
            AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
            [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
            [session addOutput:metadataOutput]; // 这行代码要在设置 metadataObjectTypes 前
            metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
            
            AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            previewLayer.frame = self.view.frame;
            [self.view.layer insertSublayer:previewLayer atIndex:0];
            
            __weak typeof(self) weakSelf = self;
            [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification
                                                              object:nil
                                                               queue:[NSOperationQueue currentQueue]
                                                          usingBlock: ^(NSNotification *_Nonnull note) {
                                                              metadataOutput.rectOfInterest = [previewLayer metadataOutputRectOfInterestForRect:weakSelf.scanRect]; // 如果不设置，整个屏幕都可以扫
                                                          }];
            
            QRScanView *scanView = [[QRScanView alloc] initWithScanRect:self.scanRect];
            [self.view addSubview:scanView];
            
            [session startRunning];
        } else {
            NSLog(@"%@", error);
        }
    });
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {

    AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
    if ([metadataObject.type isEqualToString:AVMetadataObjectTypeQRCode] && !self.isQRCodeCaptured) {
        self.isQRCodeCaptured = YES;
        qrCodeContent=metadataObject.stringValue;
        [self performSegueWithIdentifier:@"jionAccountBookSegue" sender:self];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy:CIDetectorAccuracyHigh }];
    CIImage *image = [[CIImage alloc] initWithImage:originalImage];
    NSArray *features = [detector featuresInImage:image];
    CIQRCodeFeature *feature = [features firstObject];
    if (feature) {
        qrCodeContent=feature.messageString;
        [self performSegueWithIdentifier:@"jionAccountBookSegue" sender:self];
        [picker dismissViewControllerAnimated:YES completion:nil];
    } else {
        if(DEBUG) {
            NSLog(@"No QR Code found!");
        }
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
