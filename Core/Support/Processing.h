//
//  Processing.h
//  Pods
//
//  Created by lidaye on 04/08/2017.
//
//

#import <Foundation/Foundation.h>

@interface Processing : NSObject

@property (nonatomic) double sync;
@property (nonatomic) double secret;
@property (nonatomic) double network;
@property (nonatomic) double total;

- (BOOL)dataSynchronized;
- (BOOL)secretSharing;
- (BOOL)networkFinished;

@end
