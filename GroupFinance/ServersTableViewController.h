//
//  ServersTableViewController.h
//  GroupFinance
//
//  Created by lidaye on 19/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServersTableViewController : UITableViewController

@property (nonatomic) NSInteger sent;

@property (weak, nonatomic) IBOutlet UITextField *groupIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *groupNameTextField;

@property (weak, nonatomic) IBOutlet UIView *groupInformationView;
@property (weak, nonatomic) IBOutlet UILabel *noServerLabel;
@property (weak, nonatomic) IBOutlet UIButton *initialGroupButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addServerBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *restoreServerBarButtonItem;

- (IBAction)initialGroup:(id)sender;

@end
