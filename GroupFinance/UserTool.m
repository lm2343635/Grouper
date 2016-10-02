//
//  UserTool.m
//  GroupFinance
//
//  Created by lidaye on 02/10/2016.
//  Copyright © 2016 limeng. All rights reserved.
//

#import "UserTool.h"


@implementation UserTool {
    NSUserDefaults *defaults;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

@synthesize email = _email;

- (void)setEmail:(NSString *)email {
    _email = email;
    [defaults setObject:_email forKey:NSStringFromSelector(@selector(email))];
}

- (NSString *)email {
    if(_email == nil) {
        _email = [defaults objectForKey:NSStringFromSelector(@selector(email))];
    }
    return _email;
}

@synthesize gender = _gender;

- (void)setGender:(NSString *)gender {
    _gender = gender;
    [defaults setObject:_gender forKey:NSStringFromSelector(@selector(gender))];
}

- (NSString *)gender {
    if (_gender == nil) {
        _gender = [defaults objectForKey:NSStringFromSelector(@selector(gender))];
    }
    return _gender;
}

@synthesize name = _name;

- (void)setName:(NSString *)name {
    _name = name;
    [defaults setObject:_name forKey:NSStringFromSelector(@selector(name))];
}

- (NSString *)name {
    if(_name == nil) {
        _name = [defaults objectForKey:NSStringFromSelector(@selector(name))];
    }
    return _name;
}

@synthesize picture = _picture;

- (void)setPicture:(NSData *)picture {
    _picture = picture;
    [defaults setObject:_picture forKey:NSStringFromSelector(@selector(picture))];
}

- (NSData *)picture {
    if (_picture == nil) {
        _picture = [defaults objectForKey:NSStringFromSelector(@selector(picture))];
    }
    return _picture;
}

@synthesize pictureUrl = _pictureUrl;

- (void)setPictureUrl:(NSString *)pictureUrl {
    _pictureUrl = pictureUrl;
    [defaults setObject:_pictureUrl forKey:NSStringFromSelector(@selector(pictureUrl))];
}

- (NSString *)pictureUrl {
    if (_pictureUrl == nil) {
        _pictureUrl = [defaults objectForKey:NSStringFromSelector(@selector(pictureUrl))];
    }
    return _pictureUrl;
}

@synthesize userId = _userId;

- (void)setUserId:(NSString *)userId {
    _userId = userId;
    [defaults setObject:_userId forKey:NSStringFromSelector(@selector(userId))];
}

- (NSString *)userId {
    if (_userId == nil) {
        _userId = [defaults objectForKey:NSStringFromSelector(@selector(userId))];
    }
    return _userId;
}

@end
