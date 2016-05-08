//
//  MultipeerManager.m
//  GroupFinance
//
//  Created by lidaye on 4/23/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "MultipeerManager.h"
#import <Ensembles/Ensembles.h>

NSString *const SyncPeerService=@"group";
NSString *const kDiscoveryInfoUniqueIdentifer = @"DiscoveryInfoUniqueIdentifer";

@interface MultipeerManager() <MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate> {
    NSString *uniqueIdentifer;
    MCSession *peerSession;
    MCNearbyServiceBrowser *peerBrowser;
    MCNearbyServiceAdvertiser *peerAdvertiser;
}

@end

@implementation MultipeerManager

- (instancetype)init {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    self=[super init];
    if(self) {
        uniqueIdentifer=[[NSProcessInfo processInfo] globallyUniqueString];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopAndStart)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Start and stop connecting
- (void)start {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if(peerSession&&peerAdvertiser&&peerBrowser) {
        return;
    }
    [self stop];
    MCPeerID *peerID=[[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    peerSession=[[MCSession alloc] initWithPeer:peerID
                               securityIdentity:nil
                           encryptionPreference:MCEncryptionRequired];
    peerSession.delegate=self;
    
    peerAdvertiser=[[MCNearbyServiceAdvertiser alloc] initWithPeer:peerID
                                                     discoveryInfo:@{kDiscoveryInfoUniqueIdentifer: uniqueIdentifer}
                                                       serviceType:SyncPeerService];
    peerAdvertiser.delegate=self;
    [peerAdvertiser startAdvertisingPeer];
    
    peerBrowser=[[MCNearbyServiceBrowser alloc] initWithPeer:peerID
                                                 serviceType:SyncPeerService];
    peerBrowser.delegate=self;
    [peerBrowser startBrowsingForPeers];
}

- (void)stop {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    peerSession.delegate=nil;
    [peerSession disconnect];
    peerSession=nil;
    
    peerBrowser.delegate=nil;
    [peerBrowser stopBrowsingForPeers];
    peerBrowser=nil;
    
    peerAdvertiser.delegate=nil;
    [peerAdvertiser stopAdvertisingPeer];
    peerAdvertiser=nil;
}

- (void)stopAndStart {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self stop];
    [self start];
}

#pragma mark - Syncing Files
- (void)syncFileWithAllPeers {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if (peerSession.connectedPeers.count == 0 && (!peerBrowser || !peerAdvertiser) ) {
        [self start];
        return;
    }
    
    NSMutableArray *peers = [peerSession.connectedPeers mutableCopy];
    [peers removeObject:peerSession.myPeerID];
    [self.multipeerCloudFileSystem retrieveFilesFromPeersWithIDs:peers];
}

- (BOOL)sendAndDiscardFileAtURL:(NSURL *)url toPeerWithID:(id<NSObject,NSCopying,NSCoding>)peerID {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSProgress *progress=[peerSession sendResourceAtURL:url
                                               withName:[url lastPathComponent]
                                                 toPeer:(id)peerID
                                  withCompletionHandler:^(NSError * _Nullable error) {
                                      if (error) CDELog(CDELoggingLevelError, @"Failed to send resource to peerID: %@", peerID);
                                      [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
                                  }];
    return progress!=nil;
}

- (BOOL)sendData:(NSData *)data toPeerWithID:(id<NSObject,NSCopying,NSCoding>)peerID {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSError *error;
    BOOL success=[peerSession sendData:data
                               toPeers:@[peerID]
                              withMode:MCSessionSendDataReliable
                                 error:&error];
    if (!success) {
        CDELog(CDELoggingLevelError, @"Failed to send data to peer: %@", error);
    }
    return success;
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self.multipeerCloudFileSystem receiveData:data
                                fromPeerWithID:peerID];
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if(localURL==nil) {
        return;
    }
    [self.multipeerCloudFileSystem receiveResourceAtURL:localURL
                                         fromPeerWithID:peerID];
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if(state==MCSessionStateNotConnected) {
        [peerBrowser startBrowsingForPeers];
        [peerAdvertiser startAdvertisingPeer];
    } else if(state==MCSessionStateConnected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self syncFileWithAllPeers];
        });
    }
}

#pragma mark - MCNearbyServiceBrowserDelegate
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary<NSString *,NSString *> *)info {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    if([peerID isEqual:peerSession.myPeerID]) {
        return;
    }
    if([peerSession.connectedPeers containsObject:peerID]) {
        return;
    }
    NSString *otherPeerUniqueIdentifer=info[kDiscoveryInfoUniqueIdentifer];
    BOOL shouldAccept=([otherPeerUniqueIdentifer compare:uniqueIdentifer]!=NSOrderedDescending);
    if(!shouldAccept) {
        return;
    }
    NSData *context=[uniqueIdentifer dataUsingEncoding:NSUTF8StringEncoding];
    [browser invitePeer:peerID
              toSession:peerSession
            withContext:context
                timeout:30.0];
    CDELog(CDELoggingLevelVerbose, @"Inviting %@", peerID.displayName);
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    peerSession=nil;
}

#pragma mark - MCNearbyServiceAdvertiserDelegate 
-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL, MCSession * _Nonnull))invitationHandler {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    NSString *otherPeerUniqueIdentifer=[NSString stringWithUTF8String:context.bytes];
    BOOL shouldInvite=([otherPeerUniqueIdentifer compare:uniqueIdentifer]==NSOrderedDescending);
    if(![peerSession.connectedPeers containsObject:peerID]&&shouldInvite) {
        CDELog(CDELoggingLevelVerbose, @"Accepting invite from peer %@", peerID.displayName);
        invitationHandler(YES, peerSession);
    } else {
        CDELog(CDELoggingLevelVerbose, @"Rejecting invite from %@, because it is already in session", peerID.displayName);
        invitationHandler(NO, peerSession);
    }
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {
    if(DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    peerAdvertiser=nil;
}
@end
