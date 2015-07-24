//
//  EMFirstViewController.h
//  EchoMobile
//
//  Created by TechM . on 30/09/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CFStringRef const kCTCellMonitorCellType;
extern CFStringRef const kCTCellMonitorCellTypeServing;
extern CFStringRef const kCTCellMonitorCellTypeNeighbor;
extern CFStringRef const kCTCellMonitorCellId;
extern CFStringRef const kCTCellMonitorLAC;
extern CFStringRef const kCTCellMonitorMCC;
extern CFStringRef const kCTCellMonitorMNC;
extern CFStringRef const kCTCellMonitorUpdateNotification;
extern CFStringRef const kCTCellMonitorRSCP;
extern CFStringRef const kCTCellMonitorECN0;
extern CFStringRef const kCTCellMonitorBandInfo;
extern CFStringRef const kCTCellMonitorARFCN;
extern CFStringRef const kCTCellMonitorSectorLong;
extern CFStringRef const kCTCellMonitorSectorLat;
extern CFStringRef const kCTCellMonitorCellRadioAccessTechnology;



struct CTResult
{
    int flag;
    int a;
};

@interface EMFirstViewController : UITableViewController

@property (strong, nonatomic) NSArray *params;
@property (strong, nonatomic) NSString *rssi;
@property (strong, nonatomic) NSString *cellId;
@property (strong, nonatomic) NSString *lac;
@property (strong, nonatomic) NSString *ber;
@property (strong, nonatomic) NSString *psState;
@property (strong, nonatomic) NSString *band;
@property (strong, nonatomic) NSString *rxch;
@property (strong, nonatomic) NSString *txch;
@property (strong, nonatomic) NSString *snr;
@property (strong, nonatomic) NSString *mcc;
@property (strong, nonatomic) NSString *mnc;
@property (strong, nonatomic) NSString *msisdn;
@property (strong, nonatomic) NSString *imsi;
@property (strong, nonatomic) NSString *rsrq;
@property (strong, nonatomic) NSString *rsrp;
@property (strong, nonatomic) NSString *tac;
@property (strong, nonatomic) NSString *phyCellId;
@property (strong, nonatomic) NSString *rscp;
@property (strong, nonatomic) NSString *ecio;
@property (strong, nonatomic) NSString *bandInfo;
@property (strong, nonatomic) NSString *arfcn;
@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *lattitude;
@property (strong, nonatomic) NSString *radioAccessTech;

//int CellMonitorCallback(id connection, CFStringRef string, CFDictionaryRef dictionary, void *data);
//-(int) CellMonitorCallback:(id)connection withString:(CFStringRef)string usingDictionary:(CFDictionaryRef) dictionary andData:(void*)data;

id _CTServerConnectionCreate(CFAllocatorRef, void*, int*);
void _CTServerConnectionAddToRunLoop(id, CFRunLoopRef, CFStringRef);

#ifdef __LP64__

void _CTServerConnectionRegisterForNotification(id, CFStringRef);
void _CTServerConnectionCellMonitorStart(id);
void _CTServerConnectionCellMonitorStop(id);
void _CTServerConnectionCellMonitorCopyCellInfo(id, void*, CFArrayRef*);

#else

void _CTServerConnectionRegisterForNotification(struct CTResult*, id, CFStringRef);
#define _CTServerConnectionRegisterForNotification(connection, notification) { struct CTResult res; _CTServerConnectionRegisterForNotification(&res, connection, notification); }

void _CTServerConnectionCellMonitorStart(struct CTResult*, id);
#define _CTServerConnectionCellMonitorStart(connection) { struct CTResult res; _CTServerConnectionCellMonitorStart(&res, connection); }

void _CTServerConnectionCellMonitorStop(struct CTResult*, id);
#define _CTServerConnectionCellMonitorStop(connection) { struct CTResult res; _CTServerConnectionCellMonitorStop(&res, connection); }

void _CTServerConnectionCellMonitorCopyCellInfo(struct CTResult*, id, void*, CFArrayRef*);
#define _CTServerConnectionCellMonitorCopyCellInfo(connection, tmp, cells) { struct CTResult res; _CTServerConnectionCellMonitorCopyCellInfo(&res, connection, tmp, cells); }

#endif

@end

static EMFirstViewController* gSelf;