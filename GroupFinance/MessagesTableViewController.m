//
//  MessagesTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 03/04/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "MessagesTableViewController.h"
#import "DaoManager.h"

@interface MessagesTableViewController ()

@end

@implementation MessagesTableViewController {
    DaoManager *dao;
    NSMutableArray *messages;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao = [DaoManager sharedInstance];
    messages = [NSMutableArray arrayWithArray:[dao.messageDao findNormal]];
}


#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return 0.01;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    return messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Message *message = [messages objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageIdentifier" forIndexPath:indexPath];
    UILabel *senderNameLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *receiverNameLabel = (UILabel *)[cell viewWithTag:3];
    UILabel *info1Label = (UILabel *)[cell viewWithTag:5];
    UILabel *info2Label = (UILabel *)[cell viewWithTag:6];
    senderNameLabel.text = message.sender;
    receiverNameLabel.text = message.receiver;
    info1Label.text = [NSString stringWithFormat:@"Send at %@", message.sendtime];
    info2Label.text = [NSString stringWithFormat:@"%@, %@", message.type, message.object];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    Message *message = [messages objectAtIndex:indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [dao.context deleteObject:message];
        [dao saveContext];
        [messages removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
