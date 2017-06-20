//
//  JoinGroupViewController.h
//  Grouper
//
//  Created by 李大爷的电脑 on 04/06/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JoinGroupViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *devicesTableView;

- (IBAction)browseForDevices:(id)sender;

@end
