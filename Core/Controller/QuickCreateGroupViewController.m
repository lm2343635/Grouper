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
#import "CommonTool.h"

/**
Demo JSON String.
 
{
    "groupId": "test",
    "groupName": "Test Group",
    "threshold": "20",
    "safe": "25",
    "intervalTime": "10",
    "servers": [
        "grouper1.softlab.cs.tsukuba.ac.jp",
        "grouper2.softlab.cs.tsukuba.ac.jp",
        "grouper3.softlab.cs.tsukuba.ac.jp",
        "grouper4.softlab.cs.tsukuba.ac.jp",
        "grouper5.softlab.cs.tsukuba.ac.jp",
        "grouper6.softlab.cs.tsukuba.ac.jp",
        "grouper7.softlab.cs.tsukuba.ac.jp",
        "grouper8.softlab.cs.tsukuba.ac.jp",
        "grouper9.softlab.cs.tsukuba.ac.jp",
        "grouper10.softlab.cs.tsukuba.ac.jp",
        "grouper11.softlab.cs.tsukuba.ac.jp",
        "grouper12.softlab.cs.tsukuba.ac.jp",
        "grouper13.softlab.cs.tsukuba.ac.jp",
        "grouper14.softlab.cs.tsukuba.ac.jp",
        "grouper15.softlab.cs.tsukuba.ac.jp",
        "grouper16.softlab.cs.tsukuba.ac.jp",
        "grouper17.softlab.cs.tsukuba.ac.jp",
        "grouper18.softlab.cs.tsukuba.ac.jp",
        "grouper19.softlab.cs.tsukuba.ac.jp",
        "grouper20.softlab.cs.tsukuba.ac.jp",
        "grouper21.softlab.cs.tsukuba.ac.jp",
        "grouper22.softlab.cs.tsukuba.ac.jp",
        "grouper23.softlab.cs.tsukuba.ac.jp",
        "grouper24.softlab.cs.tsukuba.ac.jp",
        "grouper25.softlab.cs.tsukuba.ac.jp",
        "grouper26.softlab.cs.tsukuba.ac.jp",
        "grouper27.softlab.cs.tsukuba.ac.jp",
        "grouper28.softlab.cs.tsukuba.ac.jp",
        "grouper29.softlab.cs.tsukuba.ac.jp",
        "grouper30.softlab.cs.tsukuba.ac.jp"
    ]
}
 */

#define DemoJSON @"{\n    \"groupId\": \"\",\n    \"groupName\": \"\", \n    \"threshold\": \"\", \n    \"safe\": \"\", \n    \"intervalTime\": \"\",\n    \"servers\": [\"\", \"\"]\n}"
#define kGroupId @"groupId"
#define kGroupName @"groupName"
#define kThreshold @"threshold"
#define kSafeServersCount @"safe"
#define kIntervalTime @"intervalTime"
#define kServers @"servers"

@interface QuickCreateGroupViewController ()

@end

@implementation QuickCreateGroupViewController {
    Grouper *grouper;
    int registered;
}

- (void)viewDidLoad {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    
    grouper = [Grouper sharedInstance];

    [self setCloseKeyboardAccessoryForSender:_jsonTextView];
    _jsonTextView.text = DemoJSON;
}



#pragma mark - Action
- (IBAction)quickCreateGroup:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    // If init finished, go to main storyboard.
    if (grouper.group.defaults.initial == InitialFinished) {
        [self presentViewController:[grouper.ui.main instantiateInitialViewController] animated:true completion:nil];
        return;
    }
    
    NSDictionary *config = [self parseJSONString:_jsonTextView.text];
    if (config == nil) {
        [self showTip:@"Wrong JSON string!"];
    }
    NSString *groupId = [config valueForKey:kGroupId];
    if (groupId == nil || [groupId isEqualToString:@""]) {
        [self showTip:@"groupId is not found."];
    }
    NSString *groupName = [config valueForKey:kGroupName];
    if (groupName == nil || [groupName isEqualToString:@""]) {
        [self showTip:@"groupName is not found."];
    }
    NSString *threshold = [config valueForKey:kThreshold];
    if (threshold == nil || [threshold isEqualToString:@""]) {
        [self showTip:@"threshold is not found."];
    }
    NSString *safeServersCount = [config valueForKey:kSafeServersCount];
    if (safeServersCount == nil || [safeServersCount isEqualToString:@""]) {
        [self showTip:@"safeServersCount is not found."];
    }
    NSString *intervalTime = [config valueForKey:kIntervalTime];
    if (intervalTime == nil || [intervalTime isEqualToString:@""]) {
        [self showTip:@"intervalTime is not found."];
    }
    if (![CommonTool isInteger:threshold]) {
        [self showTip:@"Threshold should be an integer!"];
        return;
    }
    if (![CommonTool isInteger:intervalTime]) {
        [self showTip:@"Inteval time should be an integer!"];
        return;
    }
    
    NSArray *servers = [config valueForKey:kServers];
    if (servers == nil) {
        [self showTip:@"servers is not found."];
    }
    
    
    // Register the new group in multiple untrusted servers.
    registered = 0;
    for (NSString *address in servers) {
        [grouper.group addNewServer:address
                      withGroupName:groupName
                         andGroupId:groupId
                         completion:^(BOOL success, NSString *message)
        {
            registered++;
            // Initialize group
            if (registered == servers.count) {
                [grouper.group initializeGroup:threshold.intValue
                              safeServersCount:safeServersCount.intValue
                                      interval:intervalTime.intValue
                                withCompletion:^(BOOL success, NSString *message)
                {
                    if (success) {
                        [self showTip:@"Create group successfully!"];
                        [_createButton setTitle:@"Start Using App" forState:UIControlStateNormal];
                    }
                    if (message != nil) {
                        [self showTip:message];
                    }
                }];

            }
                             
        }];
    }
}

#pragma mark - Service
- (NSDictionary *)parseJSONString:(NSString *)string {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
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

- (void)setCloseKeyboardAccessoryForSender:(id)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    UIToolbar * topView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    [topView setBarStyle:UIBarStyleDefault];
    UIBarButtonItem* spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                     target:self
                                                                                     action:nil];
    UIBarButtonItem *doneButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                  target:self
                                                                                  action:@selector(editFinish)];
    
    NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButtonItem,doneButtonItem,nil];
    [topView setItems:buttonsArray];
    [sender setInputAccessoryView:topView];
}

- (void)editFinish {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    [_jsonTextView resignFirstResponder];
}

@end
