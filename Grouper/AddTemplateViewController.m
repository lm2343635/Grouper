//
//  AddTemplateViewController.m
//  GroupFinance
//
//  Created by lidaye on 6/5/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "AddTemplateViewController.h"
#import "SelectRecordItemTableViewController.h"
#import "UIViewController+Extension.h"
#import "Grouper.h"

@interface AddTemplateViewController ()

@end

@implementation AddTemplateViewController {
    DaoManager *dao;
    User *currentUser;
    NSUInteger selectItemType;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao = [DaoManager sharedInstance];
    currentUser = [[GroupManager sharedInstance] currentUser];
    
    if (_recordType == nil) {
        _recordType=[NSNumber numberWithBool:NO];
    }
    if (_recordType != nil) {
        [_saveTypeSwitch setOn:_recordType.boolValue];
    }

    if (_selectedClassification != nil) {
        [_selectClassificationButton setTitle:_selectedClassification.cname
                                     forState:UIControlStateNormal];
    }
    if (_selectedAccount != nil) {
        [_selectAccountButton setTitle:_selectedAccount.aname
                              forState:UIControlStateNormal];
    }
    if (_selectedShop != nil) {
        [_selectShopButton setTitle:_selectedShop.sname
                           forState:UIControlStateNormal];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (_item == nil) {
        return;
    }
    switch (selectItemType) {
        case SELECT_ITEM_TYPE_CLASSIFICATION:
            _selectedClassification = (Classification *)_item;
            [_selectClassificationButton setTitle:_selectedClassification.cname
                                         forState:UIControlStateNormal];
            break;
        case SELECT_ITEM_TYPE_ACCOUNT:
            _selectedAccount = (Account *)_item;
            [_selectAccountButton setTitle:_selectedAccount.aname
                                  forState:UIControlStateNormal];
            break;
        case SELECT_ITEM_TYPE_SHOP:
            _selectedShop = (Shop *)_item;
            [_selectShopButton setTitle:_selectedShop.sname
                               forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [textView resignFirstResponder];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if([segue.identifier isEqualToString:@"templateRecordItemSegue"]) {
        UIViewController *controller=[segue destinationViewController];
        [controller setValue:[NSNumber numberWithInteger:selectItemType] forKey:@"selectItemType"];
    }
}

#pragma mark - Navigation
- (void)save:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([_templateNameTextField.text isEqual:@""]) {
        [self showWarning:@"Tempate name is empty!"];
        return;
    }
    if (_selectedClassification == nil || _selectedAccount == nil || _selectedShop == nil) {
        [self showWarning:@"Classification, account or shop is empty!"];
        return;
    }
    Template *template = [dao.templateDao saveWithNname:_templateNameTextField.text
                                          andRecordType:_recordType
                                      andClassification:_selectedClassification
                                             andAccount:_selectedAccount
                                                andShop:_selectedShop
                                                creator:currentUser.email];
    [[SendManager sharedInstance] update:template];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)selectClassification:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    _item =  nil;
    selectItemType = SELECT_ITEM_TYPE_CLASSIFICATION;
    [self performSegueWithIdentifier:@"templateRecordItemSegue" sender:self];
}

- (IBAction)selectAccount:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    _item = nil;
    selectItemType = SELECT_ITEM_TYPE_ACCOUNT;
    [self performSegueWithIdentifier:@"templateRecordItemSegue" sender:self];
}

- (IBAction)selectShop:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    _item = nil;
    selectItemType = SELECT_ITEM_TYPE_SHOP;
    [self performSegueWithIdentifier:@"templateRecordItemSegue" sender:self];
}

- (void)changeSaveType:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if ([sender isOn]) {
        _recordType = [NSNumber numberWithBool:YES];
        _saveTypeLabel.text = @"Save as Earn";
    } else {
        _recordType = [NSNumber numberWithBool:NO];
        _saveTypeLabel.text = @"Save as Spend";
    }
}

@end
