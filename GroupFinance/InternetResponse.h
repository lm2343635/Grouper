//
//  InternetResponse.h
//  GroupFinance
//
//  Created by 李大爷的电脑 on 06/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface InternetResponse : NSObject

typedef NS_OPTIONS(NSUInteger, ErrorCode) {
    
    ErrorNotConnectedToInternet = -1009,
    
    ErrorMasterKey = 901,
    ErrorAccessKey = 902,
    ErrorMasterOrAccessKey = 903,
    
    ErrorGroupExsit = 1011,
    ErrorGroupRegister = 1012,
    ErrorUserNotMatch = 1031,
    ErrorGroupInitialized = 1041,

    ErrorAddUser = 2011,
    ErrorPushNoPrivilege = 2051,
    
    ErrorNoReceiverFound = 3011,
    ErrorPutShare = 3012,
    ErrorSendSelfForbidden = 3013,
    ErrorNoShareFound = 3031,
    ErrorMessageIdShareFormat = 3051
    
};

@property (nonatomic, strong) NSObject *data;

//init with Internet response
- (instancetype)initWithResponseObject:(id)responseObject;

//Init with error
- (instancetype)initWithError:(NSError *)error;

//response status is 200
- (BOOL)statusOK;

//response result
- (id)getResponseResult;

//getErrorCode
- (int)errorCode;

@end
