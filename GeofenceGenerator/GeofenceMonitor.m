//
//  GeofenceMonitor.m
//  GeofenceGenerator
//
//  Created by Eric Lee on 11/4/14.
//  Copyright (c) 2014 Eric Lee. All rights reserved.
//

#import "GeofenceMonitor.h"

@implementation GeofenceMonitor
@synthesize locationManager;
+(GeofenceMonitor *) sharedObj
{
    
    static GeofenceMonitor * shared =nil;
    
    static dispatch_once_t onceTocken;
    dispatch_once(&onceTocken, ^{
        shared = [[GeofenceMonitor alloc] init];
    });
    return shared;
}

- (CLRegion*)dictToRegion:(NSDictionary*)dictionary
{
    NSString *identifier = [dictionary valueForKey:@"identifier"];
    CLLocationDegrees latitude = [[dictionary valueForKey:@"latitude"] doubleValue];
    CLLocationDegrees longitude =[[dictionary valueForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    CLLocationDistance regionRadius = [[dictionary valueForKey:@"radius"] doubleValue];
    
    if(regionRadius > locationManager.maximumRegionMonitoringDistance)
    {
        regionRadius = locationManager.maximumRegionMonitoringDistance;
    }
    
    NSString *version = [[UIDevice currentDevice] systemVersion];
    CLRegion * region =nil;
    
    if([version floatValue] >= 7.0f) //for iOS7
    {
        region =  [[CLCircularRegion alloc] initWithCenter:centerCoordinate
                                                    radius:regionRadius
                                                identifier:identifier];
    }
    else // iOS 7 below
    {
        region = [[CLRegion alloc] initCircularRegionWithCenter:centerCoordinate
                                                         radius:regionRadius
                                                     identifier:identifier];
    }
    return  region;
}

-(id) init
{
    self = [super init];
    if(self)
    {
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
    }
    return self;
}
-(void) showMessage:(NSString *) message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Geofence"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:Nil, nil];
    
    alertView.alertViewStyle = UIAlertViewStyleDefault;
    
    [alertView show];
    
    
}
-(BOOL) checkLocationManager
{
    if(![CLLocationManager locationServicesEnabled])
    {
        [self showMessage:@"You need to enable Location Services"];
        return  FALSE;
    }
    NSLog(@"%i  ", [CLLocationManager isMonitoringAvailableForClass:self.class]);
    if(![CLLocationManager isMonitoringAvailableForClass:self.class])
    {
        [self showMessage:@"Region monitoring is not available for this Class"];
        return  FALSE;
    }
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
       [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted  )
    {
        [self showMessage:@"You need to authorize Location Services for the APP"];
        return  FALSE;
    }
    return TRUE;
}

-(void) addGeofence:(NSDictionary*) dict
{
    
    CLRegion * region = [self dictToRegion:dict];
    [locationManager startMonitoringForRegion:region];
}

-(void) findCurrentFence
{
    NSString *version = [[UIDevice currentDevice] systemVersion];
    
    if([version floatValue] >= 7.0f) //for iOS7
    {
        
        NSArray * monitoredRegions = [locationManager.monitoredRegions allObjects];
        for(CLRegion *region in monitoredRegions)
        {
            [locationManager requestStateForRegion:region];
        }
    }
    else
    {
        [locationManager startUpdatingLocation];
    }
    
}
-(void) removeGeofence:(NSDictionary*) dict
{
    CLRegion * region = [self dictToRegion:dict];
    [locationManager stopMonitoringForRegion:region];
    
    
}
-(void) clearGeofences
{
    NSArray * monitoredRegions = [locationManager.monitoredRegions allObjects];
    for(CLRegion *region in monitoredRegions) {
        [locationManager stopMonitoringForRegion:region];
        
        NSLog(@"Geofence of %@ has been cleared.", region);
    }
    
}



/*
 Delegate Methods
 */

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.applicationIconBadgeNumber = 1;
    
    if(state == CLRegionStateInside)
    {
        NSLog(@"##Entered Region - %@", region.identifier);
        notification.alertBody = @"Entered the Geofence";
    }
    else if(state == CLRegionStateOutside)
    {
        NSLog(@"##Exited Region - %@", region.identifier);
        notification.alertBody = @"Exited the Geofence";
    }
    else{
        NSLog(@"##Unknown state  Region - %@", region.identifier);
        notification.alertBody = @"Unknown state of the Geofence";
    }
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];

}
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"Started monitoring %@ region", region.identifier);
}
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.applicationIconBadgeNumber = 1;
    notification.alertBody = @"Entered the Geofence";
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];

    NSLog(@"Entered Region - %@", region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.applicationIconBadgeNumber = 1;
    notification.alertBody = @"Exited the Geofence";
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    NSLog(@"Exited Region - %@", region.identifier);
}

//iOS Geofencing API provides only boundary crossing events. If a user is inside a region at the time of registration, the location manager does not generate any event. Instead, your app must wait for the user to cross the region boundary before an event is generated and sent to the delegate.

//Whenever you get first location update, check whether device is inside any fence. If the device is inside any geofence, manually invoke [locationManager: didEnterRegion:] . After getting the initial fence, we can stop the location updates.

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    static BOOL firstTime=TRUE;
    
    if(firstTime)
    {
        
        firstTime = FALSE;
        NSSet * monitoredRegions = locationManager.monitoredRegions;
        if(monitoredRegions)
        {
            [monitoredRegions enumerateObjectsUsingBlock:^(CLRegion *region,BOOL *stop)
             {
                 NSString *identifer = region.identifier;
                 CLLocationCoordinate2D centerCoords =region.center;
                 CLLocationCoordinate2D currentCoords= CLLocationCoordinate2DMake(newLocation.coordinate.latitude,newLocation.coordinate.longitude);
                 CLLocationDistance radius = region.radius;
                 
                 NSNumber * currentLocationDistance =[self calculateDistanceInMetersBetweenCoord:currentCoords coord:centerCoords];
                 if([currentLocationDistance floatValue] < radius)
                 {
                     NSLog(@"Invoking didEnterRegion Manually for region: %@",identifer);
                     
                     //stop Monitoring Region temporarily
                     [locationManager stopMonitoringForRegion:region];
                     
                     [self locationManager:locationManager didEnterRegion:region];
                     //start Monitoing Region
                     [locationManager startMonitoringForRegion:region];
                 }
             }];
        }
        //Stop Location Updation, we dont need it now.
        [locationManager stopUpdatingLocation];
        
    }
}

//Helper Functions - Calculate distance between two coordinates.
- (NSNumber*)calculateDistanceInMetersBetweenCoord:(CLLocationCoordinate2D)coord1 coord:(CLLocationCoordinate2D)coord2 {
    NSInteger nRadius = 6371; // Earth's radius in Kilometers
    double latDiff = (coord2.latitude - coord1.latitude) * (M_PI/180);
    double lonDiff = (coord2.longitude - coord1.longitude) * (M_PI/180);
    double lat1InRadians = coord1.latitude * (M_PI/180);
    double lat2InRadians = coord2.latitude * (M_PI/180);
    double nA = pow ( sin(latDiff/2), 2 ) + cos(lat1InRadians) * cos(lat2InRadians) * pow ( sin(lonDiff/2), 2 );
    double nC = 2 * atan2( sqrt(nA), sqrt( 1 - nA ));
    double nD = nRadius * nC;
    // convert to meters
    return @(nD*1000);
}



@end
