//
//  EMCallViewController.m
//  EchoMobile
//
//  Created by Macmini on 27/10/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import "EMCallViewController.h"
#import "EMVoiceCall.h"

@interface EMCallViewController ()

@end

@implementation EMCallViewController

@synthesize numberTF,durationLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)callButtonClicked:(id)sender {
//    NSString *phoneNumber = [@"tel://" stringByAppendingString:self.numberTF.text];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    
    [EMVoiceCall callPhoneNumber:self.numberTF.text
                            call:^(NSTimeInterval duration) {
        NSLog(@"User made a call of %.1f seconds  ", duration);}
                          cancel:^{NSLog(@"User cancelled the call");
     }];
}


@end
