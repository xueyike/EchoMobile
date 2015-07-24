//
//  EMSecondViewController.m
//  EchoMobile
//
//  Created by TechM . on 30/09/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import "EMSecondViewController.h"

//#define CORETELPATH "/System/Library/PrivateFrameworks/CoreTelephony.framework/CoreTelephony" // new
//
//id(*CTTelephonyCenterGetDefault)(); // new
//
//void (*CTTelephonyCenterAddObserver) (id,id,CFNotificationCallback,NSString*,void*,int);// new
//

@interface EMSecondViewController ()

@end

@implementation EMSecondViewController
@synthesize callButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    UIImage *image = [[UIImage imageNamed:@"call.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.callButton setImage:image forState:UIControlStateNormal];
    self.callButton.tintColor = [UIColor colorWithRed:0.0f green:0.48f blue:1.0f alpha:1.0f];
    
    UIImage *image2 = [[UIImage imageNamed:@"sms.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.smsButton setImage:image2 forState:UIControlStateNormal];
    self.smsButton.tintColor = [UIColor colorWithRed:0.0f green:0.48f blue:1.0f alpha:1.0f];

    UIImage *image3 = [[UIImage imageNamed:@"download2-128.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.microBurstButton setImage:image3 forState:UIControlStateNormal];
    self.microBurstButton.tintColor = [UIColor colorWithRed:0.0f green:0.48f blue:1.0f alpha:1.0f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.callButton.tintColor = [UIColor blueColor];
    self.smsButton.tintColor = [UIColor blueColor];
}

- (IBAction)launchCallTest:(id)sender {
    //run Voice Call Test
}
- (IBAction)launchSmsTest:(id)sender {
    //run SMS Test
    NSString * timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    NSLog(@"clicked the messgae  icon at %@",timestamp);
    
    MFMessageComposeViewController *controller =
    [[MFMessageComposeViewController alloc] init];
    controller.messageComposeDelegate = self;
    
    if([MFMessageComposeViewController canSendText])
    {
        NSString *str= @"11111111111111111111111111111111111111111111111111111111111111111111111111111111";
        controller.body = str;
        controller.recipients = [NSArray arrayWithObjects:
                                 @"52577950", nil];
        controller.delegate = self;
        [self presentViewController:controller animated:YES completion:nil];
        
    }
    
}


- (void)messageComposeViewController:
(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:SSSS"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"CST"];
    [dateFormatter setTimeZone:timeZone];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    
    switch (result)
    {
        case MessageComposeResultCancelled:
            NSLog(@"Cancelled");
            break;
        case MessageComposeResultFailed:
            NSLog(@"Failed");
            break;
        case MessageComposeResultSent:
            
            NSLog(@"Message sent successfully at %@", dateString);
            
            break;
            
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

//static void telephonyEventCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
//{
//    NSString *notifyname=(NSString *)CFBridgingRelease(name);
//    if ([notifyname isEqualToString:@"kCTMessageReceivedNotification"])//received SMS
//    {
//        NSLog(@" SMS Notification Received :kCTMessageReceivedNotification");
//
//        //do something... Example: read sms.db
//
//    }else{
//        //uncomment following line to see others events
//        //NSLog(@" telephonyEventCallback Notification %@ ",notifyname);
//
//    }
//}
//
////call this method somewhere to register callback and listen sms.
//-(void) registerCallback {
//
//    void *handle = dlopen(CORETELPATH, RTLD_LAZY);
//    CTTelephonyCenterGetDefault = dlsym(handle, "CTTelephonyCenterGetDefault");
//    CTTelephonyCenterAddObserver = dlsym(handle,"CTTelephonyCenterAddObserver");
//    dlclose(handle);
//    id ct = CTTelephonyCenterGetDefault();
//
//    CTTelephonyCenterAddObserver(
//                                 ct,
//                                 NULL,
//                                 telephonyEventCallback,
//                                 NULL,
//                                 NULL,
//                                 CFNotificationSuspensionBehaviorDeliverImmediately);
//
//}

@end
