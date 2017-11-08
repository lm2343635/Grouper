//
//  Sent.h
//  AFNetworking
//
//  Created by lidaye on 08/11/2017.
//

#import <Foundation/Foundation.h>

@interface Sent : NSObject

@property (nonatomic) NSInteger success;
@property (nonatomic) NSInteger fail;
@property (nonatomic) NSInteger target;

- (instancetype)initWithTarget:(NSInteger)target;

- (BOOL)isFinished;

@end
