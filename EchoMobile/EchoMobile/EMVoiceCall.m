//
//  EMVoiceCall.m
//  EchoMobile
//
//  Created by Macmini on 03/11/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import "EMVoiceCall.h"

#define kCallSetupTime      3.0

@interface EMVoiceCall()

@property (nonatomic, strong) NSDate *callStartTime;

@property (nonatomic, copy) EMCallBlock callBlock;
@property (nonatomic, copy) EMCancelBlock cancelBlock;

@end

@implementation EMVoiceCall

#pragma mark - Internal methods

+ (instancetype)sharedInstance
{
    static EMVoiceCall *_instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (BOOL)callPhoneNumber:(NSString *)phoneNumber
                   call:(EMCallBlock)callBlock
                 cancel:(EMCancelBlock)cancelBlock
{
    if ([self validPhone:phoneNumber]) {
        
        EMVoiceCall *telPrompt = [EMVoiceCall sharedInstance];
        
        [telPrompt setNotifications];
        telPrompt.callBlock = callBlock;
        telPrompt.cancelBlock = cancelBlock;
        
        NSString *simplePhoneNumber =
        [[phoneNumber componentsSeparatedByCharactersInSet:
          [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
        
        NSString *stringURL = [@"telprompt://" stringByAppendingString:simplePhoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
        
        return YES;
    }
    return NO;
}


+ (BOOL)validPhone:(NSString*) phoneString
{
    NSTextCheckingType type = [[NSTextCheckingResult phoneNumberCheckingResultWithRange:NSMakeRange(0, phoneString.length)
                                                                            phoneNumber:phoneString] resultType];
    return type == NSTextCheckingTypePhoneNumber;
}

-(void) setNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    // save the time of the call
    
    EMAppDelegate *delegate = (EMAppDelegate *)[[UIApplication sharedApplication] delegate];
    /*
    delegate.callCenter.callEventHandler=^(CTCall* call)
    {
        //NSLog(@"Call id:%@", call.callID);
        
        if (call.callState==CTCallStateDialing)
        {
            NSLog(@"Call state:dialing");
            self.callStartTime = [NSDate date];
        }
        
    };
 */
    UIApplication *app = [UIApplication sharedApplication];
    UIBackgroundTaskIdentifier bgTask = [app beginBackgroundTaskWithName:@"MyTask" expirationHandler:^{
        NSLog(@"enterbackground1");
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        [app endBackgroundTask:bgTask];
        //bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"enterbackground2");
        // Do the work associated with the task, preferably in chunks.
        delegate.callCenter.callEventHandler=^(CTCall *call) {
            NSLog(@"call state: %@", call.callState);
        };
        for(int i=0;i<32656;i++);
        [app endBackgroundTask:bgTask];
        //bgTask = UIBackgroundTaskInvalid;
    });

}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    EMAppDelegate *delegate = (EMAppDelegate *)[[UIApplication sharedApplication] delegate];
    /*
    delegate.callCenter.callEventHandler=^(CTCall* call)
    {
        NSLog(@"Call id:%@", call.callID);
        NSLog(@"Call State:%@", call.callState);
        
        if (call.callState==CTCallStateDisconnected)
        {
            NSLog(@"Call state:disconnected");
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            
            if (self.callStartTime != nil) {
                
                if (self.callBlock != nil) {
                    self.callBlock(-([self.callStartTime timeIntervalSinceNow]) - kCallSetupTime);
                }
                
                // reset the start timer
                self.callStartTime = nil;
            }
        }
    };
*/
    /*
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.callStartTime != nil) {
        
        if (self.callBlock != nil) {
            self.callBlock(-([self.callStartTime timeIntervalSinceNow]) - kCallSetupTime);
        }
        
        // reset the start timer
        self.callStartTime = nil;
        
    } else if (self.cancelBlock != nil) {
        
        // user didn't start the call
        self.cancelBlock();
    }
     */
}


@end
