//
//  UIManager.m
//  Pods
//
//  Created by lidaye on 22/06/2017.
//
//

#import "UIManager.h"

@implementation UIManager {
    NSBundle *bundle;
}

+ (instancetype)sharedInstance {
    static UIManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UIManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSBundle *podBundle = [NSBundle bundleForClass:UIManager.self];
        bundle = [NSBundle bundleWithURL:[podBundle URLForResource:@"Grouper" withExtension:@"bundle"]];
    }
    return self;
}

@synthesize groupInit = _groupInit;

- (UIStoryboard *)groupInit {
    return [UIStoryboard storyboardWithName:@"Init" bundle:bundle];
}

@synthesize members = _members;

- (UIStoryboard *)members {
    return [UIStoryboard storyboardWithName:@"Members" bundle:bundle];
}

@end
