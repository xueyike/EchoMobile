//
//  EMMapViewController.m
//  EchoMobile
//
//  Created by TechM . on 06/10/14.
//  Copyright (c) 2014 AT&T. All rights reserved.
//

#import "EMMapViewController.h"

#define METERS_PER_MILE 1609.344

@interface EMMapViewController ()

@end

@implementation EMMapViewController
@synthesize locationManager;
@synthesize currentLocation;

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
    //fetch current location
    self.locationManager = [[CLLocationManager alloc] init]; //this ensures location service
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    self.currentLocation = [self.locationManager location];
    CLLocationCoordinate2D zoomLocation = [self.currentLocation coordinate];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, METERS_PER_MILE, METERS_PER_MILE);
    
    [self.cellMapView setRegion:viewRegion animated:YES];
    
    //add overlay
    CLLocationDistance cellRadius = 100;
    MKCircle *serving = [MKCircle circleWithCenterCoordinate:zoomLocation radius:cellRadius];
    serving.title = @"Serving";
    [self.cellMapView addOverlay:serving];
    
    CLLocationDistance cellRadiusN = 20;
    
    int totalNeighbors = 6;
    CLLocationCoordinate2D n[totalNeighbors];
    for (int i=0; i<totalNeighbors; i++) {
        n[i] = CLLocationCoordinate2DMake(zoomLocation.latitude+0.005*cos(M_PI_4*i/totalNeighbors), zoomLocation.longitude+0.005*sin(M_PI_4*i/totalNeighbors));
    }

    MKCircle *neighbor1 = [MKCircle circleWithCenterCoordinate:n[0] radius:cellRadiusN];
    neighbor1.title = @"Neighbor1";

    MKCircle *neighbor2 = [MKCircle circleWithCenterCoordinate:n[1] radius:cellRadiusN];
    neighbor2.title = @"Neighbor2";

    MKCircle *neighbor3 = [MKCircle circleWithCenterCoordinate:n[2] radius:cellRadiusN];
    neighbor3.title = @"Neighbor3";
    
    MKCircle *neighbor4 = [MKCircle circleWithCenterCoordinate:n[3] radius:cellRadiusN];
    neighbor4.title = @"Neighbor4";

    MKCircle *neighbor5 = [MKCircle circleWithCenterCoordinate:n[4] radius:cellRadiusN];
    neighbor5.title = @"Neighbor5";
    
    MKCircle *neighbor6 = [MKCircle circleWithCenterCoordinate:n[5] radius:cellRadiusN];
    neighbor6.title = @"Neighbor6";

    

    [self.cellMapView addOverlay:neighbor1];
    [self.cellMapView addOverlay:neighbor2];
    [self.cellMapView addOverlay:neighbor3];
    [self.cellMapView addOverlay:neighbor4];
    [self.cellMapView addOverlay:neighbor5];
    [self.cellMapView addOverlay:neighbor6];

    MKPointAnnotation *servingPoint = [[MKPointAnnotation alloc]init];
    servingPoint.coordinate = zoomLocation;
    servingPoint.title = @"iOSDevice";
    [self.cellMapView addAnnotation:servingPoint];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKCircle class]])
    {
        MKCircleRenderer*    aRenderer = [[MKCircleRenderer alloc] initWithCircle:(MKCircle *)overlay];
        
        aRenderer.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        aRenderer.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        aRenderer.lineWidth = 2;
        
        return aRenderer;
    }
    
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If the annotation is the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Try to dequeue an existing pin view first.
    MKPinAnnotationView*    pinView = (MKPinAnnotationView*)[mapView                                                                dequeueReusableAnnotationViewWithIdentifier:@"iOSDevice"];
    
    if (!pinView)
    {
        // If an existing pin view was not available, create one.
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                  reuseIdentifier:@"iOSDevice"];
        pinView.pinColor = MKPinAnnotationColorRed;
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
    }
    pinView.annotation = annotation;
    
    //show serving cell information in the Callout
    UILabel *information = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    information.text = @"Custom";
    pinView.leftCalloutAccessoryView = information;
    
    // detail disclosure button to display details about the annotation
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    pinView.rightCalloutAccessoryView = rightButton;
    
    return pinView;
}

#pragma mark CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations objectAtIndex:0];
    [self.locationManager stopUpdatingLocation];
    
    NSLog(@"current latitude :%f",self.currentLocation.coordinate.latitude);
    NSLog(@"current longitude :%f",self.currentLocation.coordinate.longitude);

    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:currentLocation
                   completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error)
         {
             NSLog(@"Geocode failed with error: %@", error);
             return;
         }
         
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         NSLog(@"placemark.ISOcountryCode %@",placemark.ISOcountryCode);
         self.navigationItem.title = placemark.name;
     }];
    
    [self.view setNeedsDisplay];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    self.currentLocation = newLocation;
    
    [self.view setNeedsDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
