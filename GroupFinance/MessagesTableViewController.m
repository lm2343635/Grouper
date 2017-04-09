//
//  MessagesTableViewController.m
//  GroupFinance
//
//  Created by lidaye on 03/04/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import "MessagesTableViewController.h"
#import "DaoManager.h"
#import "GroupManager.h"

@interface MessagesTableViewController ()

@end

@implementation MessagesTableViewController {
    DaoManager *dao;
    NSMutableArray *messages;
    GroupManager *group;
    NSDateFormatter *dateFormatter;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    dao = [DaoManager sharedInstance];
    messages = [NSMutableArray arrayWithArray:[dao.messageDao findNormal]];
    group = [GroupManager sharedInstance];
    
    // Init date formatter.
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
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
    UIImageView *senderAvatarImageView = (UIImageView *)[cell viewWithTag:1];
    UILabel *senderNameLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *receiverNameLabel = (UILabel *)[cell viewWithTag:3];
    UIImageView *receiverAvatarImageView = (UIImageView *)[cell viewWithTag:1];
    UILabel *infoLabel = (UILabel *)[cell viewWithTag:5];
    User *sender = group.membersDict[message.sender];
    if (sender != nil) {
        senderAvatarImageView.image = [UIImage imageWithData:sender.picture];
        senderNameLabel.text = sender.name;
    }
    User *receiver = group.membersDict[message.receiver];
    if (receiver != nil) {
        receiverAvatarImageView.image = [UIImage imageWithData:sender.picture];
        receiverNameLabel.text = message.receiver;
    }
    infoLabel.text = [NSString stringWithFormat:@"%@ | %@ | %@",
                      [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:message.sendtime.longValue]],
                      message.type, message.object];
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
