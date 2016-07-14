//
//  EditAccountBookViewController.m
//  GroupFinance
//
//  Created by lidaye on 5/15/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "EditAccountBookViewController.h"
#import "AlertTool.h"

@interface EditAccountBookViewController ()

@end

@implementation EditAccountBookViewController {
    DaoManager *dao;
}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao=[[DaoManager alloc] init];
    self.title=_accountBook.abname;
    [self createQRCode];
}

- (void)viewWillAppear:(BOOL)animated {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewWillAppear:animated];
    [_accountBookNameTextField setText:_accountBook.abname];
}

- (void)createQRCode {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSData *data=[NSJSONSerialization dataWithJSONObject:@{
                                                           @"task": @"joinAccountBook",
                                                           @"userId": [defaults valueForKey:@"userId"],
                                                           @"uniqueIdentifier": _accountBook.uniqueIdentifier
                                                           }
                                                 options:NSJSONWritingPrettyPrinted
                                                   error:nil];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:data forKey:@"inputMessage"];
    CIImage *outputImage = filter.outputImage;
    
    CGFloat scale = CGRectGetWidth(_qrCodeImageView.bounds) / CGRectGetWidth(outputImage.extent);
    CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
    CIImage *transformImage = [outputImage imageByApplyingTransform:transform];
    
    _qrCodeImageView.image = [UIImage imageWithCIImage:transformImage];
}

#pragma mark - Action
- (IBAction)saveEidt:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSString *accountBookName=_accountBookNameTextField.text;
    if([accountBookName isEqualToString:@""]) {
        UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"Tip"
                                                                               message:@"Account book name empty!"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"OK"
                                                             style:UIAlertActionStyleCancel
                                                           handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
    } else {
        _accountBook.abname=accountBookName;
        [dao saveContext];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)setAsUsing:(id)sender {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [dao.accountBookDao setUsingAccountBook:_accountBook];
    [AlertTool showAlert:[NSString stringWithFormat:@"%@ is using account book now!", _accountBook.abname]];
}
@end
