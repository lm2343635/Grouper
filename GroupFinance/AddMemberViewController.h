//
//  AddMemberViewController.h
//  GroupFinance
//
//  Created by lidaye on 22/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCManager.h"

@interface AddMemberViewController : UIViewController <MCBrowserViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *devicesTableView;

- (IBAction)browseForDevices:(id)sender;

- (void)peerDidChangeStateWithNotification: (NSNotification *)notification;

@end
