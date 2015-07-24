//
//  EMSecondViewController.h
//  EchoMobile
//
//  Created by TechM . on 30/09/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface EMSecondViewController : UIViewController <UINavigationControllerDelegate,MFMessageComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIButton *callButton;
- (IBAction)launchCallTest:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *smsButton;
- (IBAction)launchSmsTest:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *microBurstButton;

@end
