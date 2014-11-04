//
//  GeofenceMonitor.h
//  GeofenceGenerator
//
//  Created by Eric Lee on 11/4/14.
//  Copyright (c) 2014 Eric Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface GeofenceMonitor : NSObject<CLLocationManagerDelegate>
+(GeofenceMonitor *) sharedObj;

-(void) addGeofence:(NSDictionary*) dict;
-(void) removeGeofence:(NSDictionary*) dict;
-(void) clearGeofences;
-(void) findCurrentFence;
-(BOOL)checkLocationManager;
@property CLLocationManager * locationManager;
@end
