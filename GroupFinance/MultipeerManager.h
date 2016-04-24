//
//  MultipeerManager.h
//  GroupFinance
//
//  Created by lidaye on 4/23/16.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "CDEMultipeerCloudFileSystem.h"

@class CDEMultipeerCloudFileSystem;

@interface MultipeerManager : NSObject <CDEMultipeerConnection>

@property (nonatomic) CDEMultipeerCloudFileSystem *multipeerCloudFileSystem;

- (void)start;
- (void)stop;
- (void)syncFileWithAllPeers;

@end
