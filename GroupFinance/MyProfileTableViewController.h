//
//  MyProfileTableViewController.h
//  GroupFinance
//
//  Created by lidaye on 7/14/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyProfileTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthdayLabel;

- (IBAction)logout:(id)sender;

@end
