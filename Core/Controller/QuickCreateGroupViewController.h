//
//  QuickCreateGroupViewController.h
//  Pods
//
//  Created by lidaye on 02/08/2017.
//
//

#import <UIKit/UIKit.h>

@interface QuickCreateGroupViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *jsonTextView;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityIndicator;

- (IBAction)quickCreateGroup:(id)sender;

@end
