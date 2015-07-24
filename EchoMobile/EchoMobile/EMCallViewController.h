//
//  EMCallViewController.h
//  EchoMobile
//
//  Created by Macmini on 27/10/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMCallViewController : UIViewController


@property (weak, nonatomic) IBOutlet UITextField *numberTF;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

- (IBAction)callButtonClicked:(id)sender;

@end
