//
//  MCManager.h
//  MCDemo
//
//  Created by limeng on 2/12/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MCManager : NSObject <MCSessionDelegate>

@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCBrowserViewController *browserViewController;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiserAssistant;

-(void)setupPeerAndSessionWithDisplayName: (NSString *)displayName;
-(void)setupMCBrowser;
-(void)advertiseSelf: (BOOL)shouldAdvertise;

@end
