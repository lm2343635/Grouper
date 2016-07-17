//
//  EditAccountBookTableViewController.h
//  GroupFinance
//
//  Created by lidaye on 7/16/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DaoManager.h"

@interface EditAccountBookTableViewController : UITableViewController

@property (nonatomic, strong) AccountBook *accountBook;

@property (weak, nonatomic) IBOutlet UITextField *accountBookNameTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;

@property (nonatomic) NSUInteger *cooperatersCount;

- (IBAction)saveEidt:(id)sender;
- (IBAction)setAsUsing:(id)sender;

@end
