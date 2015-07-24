//
//  EMAppDelegate.h
//  EchoMobile
//
//  Created by TechM . on 30/09/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCallCenter.h>

@interface EMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CTCallCenter* callCenter;

@end
