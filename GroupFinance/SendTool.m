//
//  SendTool.m
//  GroupFinance
//
//  Created by lidaye on 04/11/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "SendTool.h"
#import "SecretSharing.h"
#import "DaoManager.h"
#import "InternetTool.h"

#define PARTS 3
#define RECOVER 2

@implementation SendTool

+ (void)sendWithSender:(Sender *)sender {
    if (DEBUG) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    AFHTTPSessionManager *manager = [InternetTool getSessionManager];
    NSArray *shares = [SecretSharing generateSharesWith:sender.content parts:PARTS recover:RECOVER];
    for (NSString *share in shares) {
        [manager POST:[InternetTool createUrl:@"transfer/send"]
           parameters:@{
                        @"sid": sender.sid,
                        @"content": share,
                        @"object": sender.object
                        }
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  InternetResponse *response = [[InternetResponse alloc] initWithResponseObject:responseObject];
                  if([response statusOK]) {
                      
                  }
              }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  InternetResponse *response = [[InternetResponse alloc] initWithError:error];
                  switch ([response errorCode]) {
                          
                      default:
                          
                          break;
                  }
              }];
    }
    //Set sender time
    sender.sendtime = [NSDate date];
    DaoManager *dao = [[DaoManager alloc] init];
    [dao saveContext];
}

@end
