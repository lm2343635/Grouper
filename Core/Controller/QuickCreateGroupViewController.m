//
//  QuickCreateGroupViewController.m
//  Pods
//
//  Created by lidaye on 02/08/2017.
//
//

#import "QuickCreateGroupViewController.h"

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

@implementation QuickCreateGroupViewController

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
    NSString *groupId = [config valueForKey:kGroupId];
    NSString *groupName = [config valueForKey:kGroupName];
    int *threshold = [[config valueForKey:kThreshold] intValue];
    int *intervalTime = [[config valueForKey:kIntervalTime] intValue];
    NSArray *servers = [config valueForKey:kServers];
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
