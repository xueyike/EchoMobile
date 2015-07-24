//
//  newEMBViewController.h
//  EchoMobile
//
//  Created by Yike Xue on 7/21/15.
//  Copyright (c) 2015 AT&T. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GCDAsyncSocket.h>
#import <GCDAsyncUdpSocket.h>

//Microburst Upload Server Control Port: 62122
//Microburst Upload Server Data Port: 62123
//Microburst Download Server Process Port: 62121
typedef NS_ENUM(uint16_t, EMBServerPort) {
    EMBServerDownloadPort = 62121,
    EMBServerControlPort = 62122,
    EMBServerUploadPort = 62123
};

typedef NS_ENUM(NSUInteger, EMBStatusTag) {
    //Name them by yourself
    EMBStatusTagNotAlive = 0,
    EMBStatusTagSocketOpened = 1,
    EMBStatusTagControlMessageSent = 2,
    EMBStatusTagControlMessageReceived = 3,
    EMBStatusTagDataTransferred = 4,
    EMBStatusTagResultReceived = 5
};

typedef NS_ENUM(NSUInteger, EMBTestMode) {
    EMBTestModeDownload = 0,
    EMBTestModeUpload = 1
};
@interface newEMBViewController : UIViewController <GCDAsyncSocketDelegate, GCDAsyncUdpSocketDelegate>

@property (weak, nonatomic) IBOutlet UITextField *packetNumInput;
@property (weak, nonatomic) IBOutlet UITextField *packetSizeInput;
@property (weak, nonatomic) IBOutlet UITextView *displayTextView;
- (IBAction)downloadTest:(id)sender;
- (IBAction)backgroundTap:(id)sender;
- (IBAction)uploadTest:(id)sender;


@end
