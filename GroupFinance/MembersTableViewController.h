//
//  MembersTableViewController.h
//  GroupFinance
//
//  Created by lidaye on 07/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCManager.h"

@interface MembersTableViewController : UITableViewController <MCBrowserViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *noMembersView;

- (IBAction)browseForDevices:(id)sender;

@end
