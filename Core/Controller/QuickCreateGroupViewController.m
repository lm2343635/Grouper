//
//  QuickCreateGroupViewController.m
//  Pods
//
//  Created by lidaye on 02/08/2017.
//
//

#import "QuickCreateGroupViewController.h"
#import "Grouper.h"
#import "UIViewController+Extension.h"

/**
Demo JSON String.
 
{
    "groupId": "test",
    "groupName": "Test Group",
    "threshold": "2",
    "intervalTime": "10",
    "servers": [
        "grouper1.softlab.cs.tsukuba.ac.jp",
        "grouper2.softlab.cs.tsukuba.ac.jp"
    ]
}
 */

#define DemoJSON @"{\n    \"groupId\": \"\",\n    \"groupName\": \"\", \n    \"threshold\": \"\", \n    \"intervalTime\": \"\",\n    \"servers\": [\"\", \"\"]\n}"
#define kGroupId @"groupId"
#define kGroupName @"groupName"
#define kThreshold @"threshold"
#define kIntervalTime @"intervalTime"
#define kServers @"servers"

@interface QuickCreateGroupViewController ()

@end

@implementation QuickCreateGroupViewController {
    Grouper *grouper;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _jsonTextView.text = DemoJSON;
}

#pragma mark - Action
- (IBAction)quickCreateGroup:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSDictionary *config = [self parseJSONString:_jsonTextView.text];
    if (config == nil) {
        [self showTip:@"Wrong JSON string!"];
    }
    NSString *groupId = [config valueForKey:kGroupId];
    if (groupId == nil) {
        [self showTip:@"groupId is not found."];
    }
    NSString *groupName = [config valueForKey:kGroupName];
    if (groupName == nil) {
        [self showTip:@"groupName is not found."];
    }
    NSString *threshold = [config valueForKey:kThreshold];
    if (threshold == nil) {
        [self showTip:@"threshold is not found."];
    }
    NSString *intervalTime = [config valueForKey:kIntervalTime];
    if (intervalTime == nil) {
        [self showTip:@"intervalTime is not found."];
    }
    NSArray *servers = [config valueForKey:kServers];
    if (servers == nil) {
        [self showTip:@"servers is not found."];
    }
    // Register the new group in multiple untrusted servers.
    for (NSString *address in servers) {
        [grouper.group addNewServer:address
                      withGroupName:groupName
                         andGroupId:groupId
                         completion:^(BOOL success, NSString *message) {
                             
                         }];
    }
}

#pragma mark - Service
- (NSDictionary *)parseJSONString:(NSString *)string {
    NSError *error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding]
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];
    if (error) {
        NSLog(@"Error serialize message %@", error.localizedDescription);
        return nil;
    }
    return dictionary;
}

@end
