//
//  AddMemberViewController.h
//  GroupFinance
//
//  Created by lidaye on 22/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddMemberViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSInteger sent;

@property (weak, nonatomic) IBOutlet UITableView *devicesTableView;

- (IBAction)browseForDevices:(id)sender;

@end
