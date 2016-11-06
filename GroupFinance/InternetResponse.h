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
    ErrorCodeTelephoneExsit = 200,
    ErrorCodeEmailExsit = 300,
    ErrorCodePasswordWrong = 301,
    ErrorCodeAccountNotFound = 302,
    ErrorCodeNotValidated = 304,
    ErrorCodeMailNeedActivate = 330,
    ErrorCodeTokenError = 350,
    ErrorCodeNotConnectedToInternet = -1009
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
