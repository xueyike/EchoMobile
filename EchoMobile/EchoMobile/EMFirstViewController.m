//
//  EMFirstViewController.m
//  EchoMobile
//
//  Created by TechM . on 30/09/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import "EMFirstViewController.h"
#import "EMParamCell.h"

@interface EMFirstViewController ()

@end

@implementation EMFirstViewController
@synthesize params;
@synthesize rssi;
@synthesize cellId;
@synthesize lac;
@synthesize ber;
@synthesize psState;
@synthesize band;
@synthesize rxch;
@synthesize txch;
@synthesize snr;
@synthesize mcc;
@synthesize mnc;
@synthesize msisdn;
@synthesize imsi;
@synthesize rsrq;
@synthesize rsrp;
@synthesize tac;
@synthesize phyCellId;
@synthesize rscp;
@synthesize ecio;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.params = [[NSArray alloc] initWithObjects:@"Radio Access Technology", @"RSSI", @"Cell ID", @"LAC", @"EcN0", @"MCC", @"MNC", @"BandInfo", @"ARFCN", @"BER", @"PS State", @"Band", @"Rx Channel", @"Tx Channel", @"Longitude", @"Lattitude", @"MSISDN", @"IMSI", @"RSRQ", @"RSRP", @"TAC", @"Physical Cell ID", @"RSCP", @"EcIo",  nil];
    
    gSelf = self;
    id CTConnection = _CTServerConnectionCreate(NULL, CellMonitorCallback, NULL);
    _CTServerConnectionAddToRunLoop(CTConnection, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    _CTServerConnectionRegisterForNotification(CTConnection, kCTCellMonitorUpdateNotification);
    _CTServerConnectionCellMonitorStart(CTConnection);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"numberOfRowsInSection: %ld",(long)[self.params count]);
	// Return the number of items.
	return [self.params count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"ROW: %ld",(long)indexPath.row);
    
    static NSString *CellIdentifier = @"ParameterCell";
    
	EMParamCell *cell = (EMParamCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	// Set up the cell.
	cell.parameterName.text = [self.params objectAtIndex:indexPath.row];
    //paramCell.textLabel.textColor = [UIColor grayColor];
    
    if(self.lac && [cell.parameterName.text isEqualToString:@"LAC"])
    {
        cell.parameterVal.text = self.lac;
        cell.parameterVal.textColor = [UIColor colorWithRed:0.0f green:0.48f blue:1.0f alpha:1.0f];
    }
    else if(self.cellId && [cell.parameterName.text isEqualToString:@"Cell ID"])
    {
        cell.parameterVal.text = self.cellId;
        cell.parameterVal.textColor = [UIColor colorWithRed:0.0f green:0.48f blue:1.0f alpha:1.0f];
    }
    else if(self.mcc && [cell.parameterName.text isEqualToString:@"MCC"])
    {
        cell.parameterVal.text = self.mcc;
        cell.parameterVal.textColor = [UIColor colorWithRed:0.0f green:0.48f blue:1.0f alpha:1.0f];
    }
    else if(self.mnc && [cell.parameterName.text isEqualToString:@"MNC"])
    {
        cell.parameterVal.text = self.mnc;
        cell.parameterVal.textColor = [UIColor colorWithRed:0.0f green:0.48f blue:1.0f alpha:1.0f];
    }
#if 0
    else if(self.rssi && [cell.parameterName.text isEqualToString:@"RSSI"])
    {
        NSString *temp = self.rssi;
        cell.parameterVal.text = [temp stringByAppendingString:@" dB"];
        cell.parameterVal.textColor = [UIColor blueColor];
    }
    else if(self.snr && [cell.parameterName.text isEqualToString:@"EcN0"])
    {
        NSString *temp = self.snr;
        cell.parameterVal.text = [temp stringByAppendingString:@" dB"];
        cell.parameterVal.textColor = [UIColor colorWithRed:0.0f green:0.48f blue:1.0f alpha:1.0f];
    }
    else if(self.cellId && [cell.parameterName.text isEqualToString:@"BandInfo"])
    {
        cell.parameterVal.text = self.bandInfo;
        cell.parameterVal.textColor = [UIColor colorWithRed:0.0f green:0.48f blue:1.0f alpha:1.0f];
    }
    else if(self.mcc && [cell.parameterName.text isEqualToString:@"ARFCN"])
    {
        cell.parameterVal.text = self.arfcn;
        cell.parameterVal.textColor = [UIColor colorWithRed:0.0f green:0.48f blue:1.0f alpha:1.0f];
    }
    else if(self.mnc && [cell.parameterName.text isEqualToString:@"Longitude"])
    {
        cell.parameterVal.text = self.longitude;
        cell.parameterVal.textColor = [UIColor colorWithRed:0.0f green:0.48f blue:1.0f alpha:1.0f];
    }
    else if(self.rssi && [cell.parameterName.text isEqualToString:@"Lattitude"])
    {
        cell.parameterVal.text = self.lattitude;
        cell.parameterVal.textColor = [UIColor colorWithRed:0.0f green:0.48f blue:1.0f alpha:1.0f];
    }
    else if(self.snr && [cell.parameterName.text isEqualToString:@"Radio Access Technology"])
    {
        NSUInteger length = [self.radioAccessTech length];
        unichar nameBuf[15];

        if(length > 35)
        {
            [self.radioAccessTech getCharacters:nameBuf range:NSMakeRange(35, length-35)];
            cell.parameterVal.text = [[NSString alloc] initWithCharacters:nameBuf length:(length-35)];
        }
        else
            cell.parameterVal.text = self.radioAccessTech;
        cell.parameterVal.textColor = [UIColor colorWithRed:0.0f green:0.48f blue:1.0f alpha:1.0f];
    }
#endif
	return cell;
}

int CellMonitorCallback(id connection, CFStringRef string, CFDictionaryRef dictionary, void *data)
{
    int tmp = 0;
    CFArrayRef cells = NULL;
    _CTServerConnectionCellMonitorCopyCellInfo(connection, (void*)&tmp, &cells);
    if (cells == NULL)
    {
        return 0;
    }
    
    for (NSDictionary* cell in (__bridge NSArray*)cells)
    {
        int LAC, CID, MCC, MNC, RSSI, SNR, BI, ARFCN, LONGITUDE, LAT;
        NSString *RAT = [[NSString alloc] init];
        
        if ([cell[(__bridge NSString*)kCTCellMonitorCellType] isEqualToString:(__bridge NSString*)kCTCellMonitorCellTypeServing])
        {
            LAC = [cell[(__bridge NSString*)kCTCellMonitorLAC] intValue];
            CID = [cell[(__bridge NSString*)kCTCellMonitorCellId] intValue];
            MCC = [cell[(__bridge NSString*)kCTCellMonitorMCC] intValue];
            MNC = [cell[(__bridge NSString*)kCTCellMonitorMNC] intValue];
            RSSI = [cell[(__bridge NSString*)kCTCellMonitorRSCP] intValue];
            SNR = [cell[(__bridge NSString*)kCTCellMonitorECN0] intValue];
            BI = [cell[(__bridge NSString*)kCTCellMonitorBandInfo] intValue];
            ARFCN = [cell[(__bridge NSString*)kCTCellMonitorARFCN] intValue];
            LONGITUDE = [cell[(__bridge NSString*)kCTCellMonitorSectorLong] intValue];
            LAT = [cell[(__bridge NSString*)kCTCellMonitorSectorLat] intValue];
            RAT = cell[(__bridge NSString*)kCTCellMonitorCellRadioAccessTechnology];
            gSelf.lac = [[NSString alloc] initWithFormat:@"%d",LAC];
            gSelf.cellId = [[NSString alloc] initWithFormat:@"%d",CID];
            gSelf.mcc = [[NSString alloc] initWithFormat:@"%d",MCC];
            gSelf.mnc = [[NSString alloc] initWithFormat:@"%d",MNC];
            gSelf.rssi = [[NSString alloc] initWithFormat:@"%d",RSSI];
            gSelf.snr = [[NSString alloc] initWithFormat:@"%d",SNR];
            gSelf.bandInfo = [[NSString alloc] initWithFormat:@"%d",BI];
            gSelf.arfcn = [[NSString alloc] initWithFormat:@"%d",ARFCN];
            gSelf.longitude = [[NSString alloc] initWithFormat:@"%d",LONGITUDE];
            gSelf.lattitude = [[NSString alloc] initWithFormat:@"%d",LAT];
            gSelf.radioAccessTech = [[NSString alloc] initWithFormat:@"%@",RAT];
        }
        else if ([cell[(__bridge NSString*)kCTCellMonitorCellType] isEqualToString:(__bridge NSString*)kCTCellMonitorCellTypeNeighbor])
        {
            LAC = [cell[(__bridge NSString*)kCTCellMonitorLAC] intValue];
            CID = [cell[(__bridge NSString*)kCTCellMonitorCellId] intValue];
            //MCC = [cell[(__bridge NSString*)kCTCellMonitorMCC] intValue];
            //MNC = [cell[(__bridge NSString*)kCTCellMonitorMNC] intValue];
        }
    }
    
    CFRelease(cells);
    if(gSelf.isViewLoaded && gSelf.tableView.window)
    {
        [gSelf.tableView reloadData];
    }
    else
    {
        
    }
    return 0;
}
@end
