//
//  MCManager.h
//  MCDemo
//
//  Created by limeng on 2/12/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#define ServiceType @"grouper"

#define MCDidChangeStateNotification @"MCDidChangeStateNotification"
#define MCDidReceiveDataNotification @"MCDidReceiveDataNotification"
#define MCDidStartReceivingResourceNotification @"MCDidStartReceivingResourceNotification"
#define MCDidFinishReceivingResourceNotification @"MCDidFinishReceivingResourceNotification"
#define MCReceivingProgressNotification @"MCReceivingProgressNotification"

@interface MultipeerConnectivityManager : NSObject <MCSessionDelegate>

@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCBrowserViewController *browserViewController;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiserAssistant;

- (void)setupPeerAndSessionWithDisplayName: (NSString *)displayName;
- (void)setupMCBrowser;
- (void)advertiseSelf: (BOOL)shouldAdvertise;

@end
