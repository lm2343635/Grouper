//
//  SelectRecordItemTableViewController.h
//  GroupFinance
//
//  Created by lidaye on 5/29/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SELECT_ITEM_TYPE_CLASSIFICATION 1
#define SELECT_ITEM_TYPE_ACCOUNT 2
#define SELECT_ITEM_TYPE_SHOP 3

@interface SelectRecordItemTableViewController : UITableViewController

@property (nonatomic, strong) NSNumber *selectItemType;

@end
