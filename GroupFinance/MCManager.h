//
//  MCManager.h
//  GroupFinance
//
//  Created by lidaye on 07/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MCManager : NSObject <MCSessionDelegate>

@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCBrowserViewController *browserViewController;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiserAssistant;

+ (MCManager *)getSingleInstance;

- (void)setupPeerAndSessionWithDisplayName: (NSString *)displayName;
- (void)setupMCBrowser;
- (void)advertiseSelf: (BOOL)shouldAdvertise;

@end
