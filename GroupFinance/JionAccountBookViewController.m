//
//  JionAccountBookViewController.m
//  GroupFinance
//
//  Created by lidaye on 7/10/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "JionAccountBookViewController.h"


@interface JionAccountBookViewController ()

@end

@implementation JionAccountBookViewController {

}

- (void)viewDidLoad {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    [self createQRCode];
}

- (void)createQRCode {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSData *data=[NSJSONSerialization dataWithJSONObject:@{
                                                           @"task": @"joinAccountBook",
                                                           @"userId": [defaults valueForKey:@"userId"]
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

@end
