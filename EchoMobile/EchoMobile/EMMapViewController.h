//
//  EMMapViewController.h
//  EchoMobile
//
//  Created by TechM . on 06/10/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface EMMapViewController : UIViewController<CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *cellMapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@end
