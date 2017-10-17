//
//  MembersManager.h
//  GroupFinance
//
//  Created by lidaye on 31/01/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDaoManager.h"
#import "Defaults.h"
#import "MultipeerConnectivityManager.h"

#define DidReceiveJoinGroupMessage @"DidReceiveJoinGroupMessage"
#define DidReceiveInviteFailedMessage @"DidReceiveInviteFailedMessage"
#define DidReceiveInviteSuccessMessage @"DidReceiveInviteSuccessMessage"

@interface GroupManager : NSObject <MCBrowserViewControllerDelegate>

// App identifier is used as service type in multipeer connectivity.
@property (nonatomic, strong) NSString *appId;

// Entities attributes is an array which constains the names of all entities saved in Core Data.
@property (nonatomic, strong) NSArray *entities;

// System parameters
@property (nonatomic, strong) Defaults *defaults;

// App Core Data stack, it should be set when app is lauching.
@property (nonatomic, strong) DataStack *appDataStack;

@property (nonatomic) BOOL isOwner;
@property (nonatomic, strong) NSMutableArray *connectedPeers;

// Current user.
@property (nonatomic, strong) User *currentUser;

// Members array.
@property (nonatomic, strong) NSMutableArray *members;

typedef void (^MemberRefreshCompletion)(BOOL);
typedef void (^CheckServerCompletion)(NSDictionary *, BOOL);
typedef void (^SucessMessageCompletion)(BOOL, NSString *);

// Get single instance.
+ (instancetype)sharedInstance;

// ******************** App Data Stack *****************

- (void)saveAppContext;

// *********************** User ************************

// Setup mutipeer connectivity so that device can be discoverd by others.
- (void)setupMutipeerConnectivity;

// Save global user email and name.
- (void)saveCurrentUserWithEmail:(NSString *)email name:(NSString *)name;

// Get a user by node
- (User *)getUserByNodeIdentifier:(NSString *)node;

// **************** Inivte Members *********************

// Open device browser.
- (void)openDeviceBroswerIn:(UIViewController *)controller;

// Send invite message to a peer.
- (void)sendInviteMessageTo:(MCPeerID *)peer;

// *************** Group Init Related ******************
    
// Add a new untrusted server.
- (void)addNewServer:(NSString *)address
       withGroupName:(NSString *)groupName
          andGroupId:(NSString *)groupId
          completion:(SucessMessageCompletion)completion;

// Restore an existed untrusted server.
- (void)restoreExistedServer:(NSString *)address
                 byAccessKey:(NSString *)key
                  completion:(SucessMessageCompletion)completion;

// Initialize group.
- (void)initializeGroup:(int)threshold
               interval:(int)interval
         withCompletion:(SucessMessageCompletion)completion;

- (BOOL)isInitialized;

// ************ Synchronization Related ****************

// Check server state, if the number of connected servers is larger than or equals to the threshold, sync with untrusted servers.
- (void)checkServerState:(CheckServerCompletion)completion;

// Clear all shareId.
- (void)clearShareId;

// Clear all messages
- (void)clearMessages;

// Clear both shareId and messages.
- (void)clear;

// ************** Device Token Related *****************

// Send device token to untrusted servers
- (void)sendDeviceToken:(NSString *)token;

// ************** Service *****************

- (NSString *)JSONStringFromObject:(NSObject *)object;

@end
