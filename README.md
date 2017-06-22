# Grouper [![Build Status](https://travis-ci.org/lm2343635/Grouper.svg?branch=master)](https://travis-ci.org/lm2343635/Grouper) [![Version](https://img.shields.io/cocoapods/v/Grouper.svg?style=flat)](http://cocoapods.org/pods/Grouper) [![License](https://img.shields.io/cocoapods/l/Grouper.svg?style=flat)](http://cocoapods.org/pods/Grouper) [![Platform](https://img.shields.io/cocoapods/p/Grouper.svg?style=flat)](http://cocoapods.org/pods/Grouper)
A framework for developing app using secret sharing and multiple untrusted servers.

## Introduction
Conventional client-server mode applications require central servers for storing shared data. The users of such mobile applications must fully trust the central server and their application providers. If a central server is compromised by hackers, user information may be revealed because data is often stored on the server in cleartext. Users may lose their data when service providers shut down their services.

Grouper uses secret sharing and multiple untrusted servers to solve this problem. In Grouper, a device use Secret Sharing scheme to divide a message into several shares and upload them to multiple untrusted servers. Other devices download shares and recover shares to original message by Secret Sharing scheme. Thus, user data can be protected. 

## Demo
We have developed an demo app called [AccountBook](https://github.com/lm2343635/AccountBook) using Grouper framework.

## Installation

Grouper is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Grouper', '~> 1.0'
```

## Documentation

Grouper uses its own Web service. The Web service by Java EE is here [Grouper-Server](https://github.com/lm2343635/Grouper-Server).

Grouper is developed with Objective-C. Import header file into your project.

```objective-c
#import <Grouper/Grouper.h>
```

### Prepare
Grouper object inclueds 3 subobject, they are group(GroupManager), sender(SenderManager), receiver(ReceiverManager).

Grouper relys on [Sync](https://github.com/SyncDB/Sync) framework to syncrhonize data between devices. Thus, when you setup Core Data stack in AppDelegate, you should use DataStack provided in [Sync](https://github.com/SyncDB/Sync) framework.

```objective-c
#pragma mark - DataStack
@synthesize dataStack = _dataStack;

- (DataStack *)dataStack {
    if (_dataStack) {
        return _dataStack;
    }
    _dataStack = [[DataStack alloc] initWithModelName:@"Model"];
    return _dataStack;
}
```

Next, set your app's data stack to Grouper.

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    grouper = [Grouper sharedInstance];
    [grouper setAppDataStack:[self dataStack]];
}
```

### Entity Design

All your Core Data entity should be subentity of SyncEntity, and all your NSManagedObjects should be subclass of SyncEntity. SyncEntity class has been provied in Grouper framework. Create SyncEntity in your Model.xcdatamodeld file and set parent entity as SyncEntity for your entity.

| Attribute | Type   | Explanation                  |
|-----------|--------|------------------------------|
| createAt  | Date   | Create date of this entity   |
| creator   | String | Creator of this entity       |
| remoteID  | String | Remote ID for Sync framework |
| updater   | String | Updater of this entity       |
| updateAt  | String | Update date of this entity   | 

### Group Management

Grouper provides group initialzation related function in Init.storyboard and member management in Members.storyboard. Use these 2 storyboards directly by **grouper.ui.groupInit** and **grouper.ui.members**.

### Data Synchronization

Grouper use SenderManager to send data and ReceiverManager to receive data. 

Use these methods to send data by grouper.sender.

```objective-c
// ******************* Create message and send shares to untrusted servers. *******************

// Send update message for a sync entity.
- (void)update:(SyncEntity *)object;

// Send delete message for a sync entity.
- (void)delete:(SyncEntity *)object;

// Send confirm message;
- (void)confirm;

// Send resend message which contains not existed sequences to receiver.
- (void)resend:(NSArray *)sequences to:(NSString *)receiver;
```

Use this method to receiver data by grouper.receiver.

```objective-c
// Receive message and do something in completion block.
- (void)receiveWithCompletion:(Completion)completion;
```

More information can be found in Demo app [AccountBook](https://github.com/lm2343635/AccountBook).

## Author

Meng Li, http://fczm.pw, lm2343635@126.com

## License

Grouper is available under the MIT license. See the LICENSE file for more info.
