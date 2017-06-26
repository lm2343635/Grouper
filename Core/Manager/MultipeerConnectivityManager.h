//
//  MCManager.h
//  MCDemo
//
//  Created by limeng on 2/12/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#define MCDidChangeStateNotification @"MCDidChangeStateNotification"
#define MCDidReceiveDataNotification @"MCDidReceiveDataNotification"
#define MCDidStartReceivingResourceNotification @"MCDidStartReceivingResourceNotification"
#define MCDidFinishReceivingResourceNotification @"MCDidFinishReceivingResourceNotification"
#define MCReceivingProgressNotification @"MCReceivingProgressNotification"

@interface MultipeerConnectivityManager : NSObject <MCSessionDelegate>

@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCBrowserViewController *browserViewController;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiserAssistant;

- (instancetype)initWithAppId:(NSString *)appId;

- (void)setupPeerAndSessionWithDisplayName: (NSString *)displayName;
- (void)setupMCBrowser;
- (void)advertiseSelf: (BOOL)shouldAdvertise;

@end
