//
//  newEMBViewController.m
//  EchoMobile
//
//  Created by Yike Xue on 7/21/15.
//  Copyright (c) 2015 AT&T. All rights reserved.


#import "newEMBViewController.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

@interface newEMBViewController ()

@property (strong, nonatomic) GCDAsyncSocket *controlSocket;
@property (strong, nonatomic) GCDAsyncUdpSocket *dataUploadSocket;
@property (strong, nonatomic) GCDAsyncUdpSocket *dataDownloadSocket;
@property (assign, nonatomic) NSInteger packetNumber;
@property (assign, nonatomic) NSInteger packetSize;
@property (assign, nonatomic) NSInteger dataPacketUploadCount;
@property (assign, nonatomic) NSInteger dataPacketDownloadCount;
@property (strong, nonatomic) NSDate *downloadTestBegin;
@property (strong, nonatomic) NSDate *downloadTestEnd;
@property (strong, nonatomic) NSDecimalNumber *downloadSpeed;
@property (strong, nonatomic) NSDecimalNumber * uploadSpeed;
@property (strong, nonatomic) NSMutableString *displayText;

@end

@implementation newEMBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _displayText = [NSMutableString stringWithFormat:@"Please tap the button to start EMB Test."];
    self.displayTextView.text = _displayText;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backgroundTap:(id)sender {
    [self.packetNumInput resignFirstResponder];
    [self.packetSizeInput resignFirstResponder];
}

- (IBAction)uploadTest:(id)sender {
    _packetNumber = [self.packetNumInput.text integerValue];
    _packetSize = [self.packetSizeInput.text integerValue];
    _displayText = [[NSMutableString alloc] init];
    [_displayText  appendString:@"\nUpload Test starting.(Now the server close the control port before sending back the upload speed."];
    self.displayTextView.text = _displayText;
    [self initNetworkSockets];
    [self startEMBUploadTest];
    
}

- (IBAction)downloadTest:(id)sender {
    _packetNumber = [self.packetNumInput.text integerValue];
    _packetSize = [self.packetSizeInput.text integerValue];
    _displayText = [[NSMutableString alloc] init];
    [_displayText  appendString:@"\nDownload Test starting."];
    self.displayTextView.text = _displayText;
    [self initNetworkSockets];
    [self startEMBDownloadTest];
}

- (void)initNetworkSockets {
    NSError *error;
    //dallecholin101.att.com 108.229.9.53
    //Linux Ubuntu
    NSURL *serverUrl = [NSURL URLWithString:@"http://108.229.9.53"];

    //GCD
    dispatch_queue_t queue = dispatch_queue_create("socketQueue", DISPATCH_QUEUE_SERIAL);
    self.controlSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:queue];
    if (![self.controlSocket connectToHost:serverUrl.host onPort:EMBServerControlPort error:&error]) {
        [_displayText appendString:[NSString stringWithFormat:@"\n error connecting to control port reason:%@", error.localizedDescription]];
        self.displayTextView.text = _displayText;
        NSLog(@"error connecting to control port reason:%@", error.localizedDescription);
    }
    self.dataUploadSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:queue];
    if (![self.dataUploadSocket connectToHost:serverUrl.host onPort:EMBServerUploadPort error:&error]) {
        [_displayText  appendString:[NSString stringWithFormat:@"\n error connecting to upload port reason:%@", error.localizedDescription]];
        self.displayTextView.text = _displayText;
        NSLog(@"error connecting to upload port reason:%@", error.localizedDescription);
    }
    self.dataDownloadSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:queue];
    if (![self.dataDownloadSocket connectToHost:serverUrl.host onPort:EMBServerDownloadPort error:&error]) {
        [_displayText  appendString:[NSString stringWithFormat:@"\n error connecting to download port reason:%@", error.localizedDescription]];        self.displayTextView.text = _displayText;
        NSLog(@"error connecting to download port reason:%@", error.localizedDescription);
    }
    
    [_displayText  appendString:@"\nInit NetworkSockets success!"];
    self.displayTextView.text = _displayText;
    NSLog(@"init NetworkSockets success!");
    NSLog(@"**********************************");
    NSLog(@"EMBStatusTagNotAlive = 0,EMBStatusTagSocketOpened = 1,EMBStatusTagControlMessageSent = 2,EMBStatusTagControlMessageReceived = 3,EMBStatusTagDataTransferred = 4,EMBStatusTagResultReceived = 5");
}

- (void)startEMBUploadTest{
    NSLog(@"----------------------------------");
    NSLog(@"Start EMB upload test");
    self.dataPacketUploadCount = 0;
    
    NSData *controlMessage = [self composeControlMessage:EMBTestModeUpload];
    [self.controlSocket writeData:controlMessage withTimeout:-1 tag:EMBStatusTagControlMessageSent];
    [self.controlSocket readDataWithTimeout:-1 tag:EMBStatusTagControlMessageReceived];
}

- (void)startEMBDownloadTest{
    NSLog(@"----------------------------------");
    NSError *error;
    NSLog(@"Start EMB download test");
    self.dataPacketDownloadCount = 0;
    NSData *controlMessage = [self composeControlMessage:EMBTestModeDownload];
    [self.dataDownloadSocket sendData:controlMessage withTimeout:-1 tag:EMBStatusTagControlMessageSent];
    [self.dataDownloadSocket beginReceiving:&error];
}

/* Compose control message to server */
- (NSData *)composeControlMessage:(EMBTestMode)mode {
    //e.g. 0:1:14:996:10.5.73.98
    /*In above example, 0 is used because it’s a Control Packet. 1 is used because it’s an Upload Test. Number of packets to be used in test are 14. Packet size to be used is 996. And IP address of Client is 10.5.73.98.
     */
    
    NSString *controlMessageStr = [NSString stringWithFormat:@"0:%lu:%lu:%lu:%@", mode, self.packetNumber, self.packetSize, [self getIPAddress]];
    [_displayText  appendString:[NSString stringWithFormat:@"\nControl Message: %@",controlMessageStr]];
    self.displayTextView.text = _displayText;
    NSLog(@"    Control Message: %@",controlMessageStr);
    return [controlMessageStr dataUsingEncoding:NSUTF8StringEncoding];
}

/* Compose data to be uploaded to server */
- (NSArray *)composeUploadData {
    
    NSMutableArray *dataArray = [NSMutableArray array];
    for (int i = 1; i <= self.packetNumber; i ++) {
        NSMutableString *dataStr = [NSMutableString stringWithFormat:@"3:%lu:%@:%d:", self.packetSize, [self getIPAddress], i];
        NSUInteger beginIndex = dataStr.length;
        for (int j = (int)beginIndex; j < self.packetSize; j ++) {
            [dataStr appendString:@"1"];
        }
        [dataArray addObject:[dataStr dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return [NSArray arrayWithArray:dataArray];
}

// Get IP Address method
- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

#pragma mark - GCD Async Socket Delegate

/* Socket connected to host */
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"----------------------------------");
    NSLog(@"Connect to %@ control port successfully", host);
    [_displayText  appendString:[NSString stringWithFormat:@"\nConnect to %@ control port successfully", host]];
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.displayTextView.text = _displayText;
    });
    
}

/* Socket read data */
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"----------------------------------");
    EMBStatusTag status = tag;
    NSLog(@"Data received from TCP. Tag: %@ status = %lu", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], tag);
    [_displayText  appendString:[NSString stringWithFormat:@"\nData received from TCP. Tag: %@ status = %lu", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], tag]];
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.displayTextView.text = _displayText;
    });
    switch (status) {
            // Uploads data to upload socket when control message is received
        case EMBStatusTagControlMessageReceived: {
            [_displayText  appendString:@"\ncontrol message received"];
//            self.displayTextView.text = _displayText;
            NSLog(@"control message received");
            NSArray *uploadData = [self composeUploadData];
            [self.controlSocket readDataWithTimeout:-1 tag:EMBStatusTagResultReceived];
            for (NSData *ud in uploadData) {
                [self.dataUploadSocket sendData:ud withTimeout:-1 tag:EMBStatusTagDataTransferred];
            }
            break;
        }
            // Receives a result packet containing upload speed
            // TODO: parse and display the result in some form
        case EMBStatusTagResultReceived:
            [_displayText  appendString:@"\nresult packet received"];
//            self.displayTextView.text = _displayText;
            NSLog(@"result packet received");
            [self.controlSocket disconnect];
            [self.dataUploadSocket close];
            [self.dataDownloadSocket close];
            break;
            
        default:
            [_displayText  appendString:@"\nsome read event from control port"];
//            self.displayTextView.text = _displayText;
            NSLog(@"some read event from control port");
            break;
    }
}

/* Socket wrote data */
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"----------------------------------");
    EMBStatusTag status = tag;
    NSLog(@"Data sent to TCP. status = %lu", tag);
    
    [_displayText  appendString:[NSString stringWithFormat:@"\nData sent to TCP. status = %lu", tag]];
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.displayTextView.text = _displayText;
    });
    
    switch (status) {
        case EMBStatusTagControlMessageSent:
            [_displayText appendString:@"\nControl message sent"];
//            self.displayTextView.text = _displayText;
            NSLog(@"Control message sent");
            break;
            
        default:
            [_displayText appendString:@"\nWrite event to control port"];
//            self.displayTextView.text = _displayText;
            NSLog(@"Write event to control port");
            break;
    }
}

/* Socket disconnected with error */
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"----------------------------------");
    // Problem: In upload test, always "socket to control port disconnected with error: Socket closed by remote peer" error and the server doesn't send back the upload speed
    NSLog(@"socket to control port disconnected with error: %@", err.localizedDescription);
    [_displayText  appendString:[NSString stringWithFormat:@"\nsocket to control port disconnected with error: %@", err.localizedDescription]];
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.displayTextView.text = _displayText;
    });
}

#pragma mark - GCD Async UDP Socket Delegate

/* UDP socket connected */
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    NSLog(@"----------------------------------");
    NSString *host = [GCDAsyncUdpSocket hostFromAddress:address];
    uint16_t port = [GCDAsyncUdpSocket portFromAddress:address];
    NSLog(@"connection to %@ data %@ port successful", host, (port == EMBServerUploadPort ? @"upload" : @"download"));
    [_displayText  appendString:[NSString stringWithFormat:@"\nconnection to %@ data %@ port successful", host, (port == EMBServerUploadPort ? @"upload" : @"download")]];
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.displayTextView.text = _displayText;
    });
}

/* UDP socket sent data */
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    NSLog(@"----------------------------------");
    NSLog(@"Data sent to UDP. status = %lu", tag);
    EMBStatusTag status = tag;
    [_displayText  appendString:[NSString stringWithFormat:@"\nData sent to UDP. status = %lu", status]];
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.displayTextView.text = _displayText;
    });
    switch (status) {
            // Increment counter after each success data upload
        case EMBStatusTagDataTransferred:
            self.dataPacketUploadCount ++;
            NSLog(@"data transfered count %lu", self.dataPacketUploadCount);
            break;
            // Control message is sent to download socket
        case EMBStatusTagControlMessageSent:
            NSLog(@"control message sent");
            break;
            
        default:
            NSLog(@"some write event to data port");
            break;
    }
}

/* UDP socket received data */
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    
    /*NSLog(@"data received from udp: %@ status = dataReceived", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);*/
    self.dataPacketDownloadCount ++;
    /*NSLog(@"data transferred count %lu", self.dataPacketDownloadCount);*/
    // Keep record of the beginning time
    if (self.dataPacketDownloadCount == 1) {
        self.downloadTestBegin = [NSDate date];
//        NSLog(@"^^^^^^^^^^^^^^^^^^^^^\nDownload START!!!!!!!!!!!!!!!\n%@",self.downloadTestBegin);
    }
    // Calculate download speed when all package is received
    if (self.dataPacketDownloadCount == self.packetNumber) {
        self.downloadTestEnd = [NSDate date];
//        NSLog(@"^^^^^^^^^^^^^^^^^^^^^\nDownload END!!!!!!!!!!!!!!!\n%@",self.downloadTestEnd);
        double timeInterval = [self.downloadTestEnd timeIntervalSinceDate:self.downloadTestBegin];
        double speed = ((self.packetNumber - 1) * self.packetSize) / timeInterval;
        NSLog(@"received all download packets in %f seconds", timeInterval);
        NSLog(@"download speed test result = %.2f KB/s, or %.2f MB/s", speed / 1000.0, speed / 1000000.0);
        [_displayText  appendString:[NSString stringWithFormat:@"\n**************************\nreceived all download packets in %f seconds\ndownload speed test result = %.2f KB/s, or %.2f MB/s", timeInterval, speed / 1000.0, speed / 1000000.0]];
        self.dataPacketDownloadCount = 0;
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.displayTextView.text = _displayText;
            [self scrollTextViewToBottom:self.displayTextView];
        });
    }
}

/* UDP socket closed with error */
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
    NSLog(@"----------------------------------");
    NSLog(@"connection to data port disconnected with error: %@", error.localizedDescription);
    [_displayText  appendString:[NSString stringWithFormat:@"\nconnection to data port disconnected with error: %@", error.localizedDescription]];
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.displayTextView.text = _displayText;
    });
}

-(void)scrollTextViewToBottom:(UITextView *)textView {
    if(textView.text.length > 0 ) {
        NSRange bottom = NSMakeRange(textView.text.length -1, 1);
        [textView scrollRangeToVisible:bottom];
    }
    
}
@end
