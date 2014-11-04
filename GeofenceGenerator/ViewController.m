//
//  ViewController.m
//  GeofenceGenerator
//
//  Created by Eric Lee on 11/4/14.
//  Copyright (c) 2014 Eric Lee. All rights reserved.
//

#import "ViewController.h"
#import "GeofenceMonitor.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //Setup addbutton design
    _addButton.layer.borderWidth=2.0f;
    [_addButton setBackgroundColor:[UIColor colorWithRed:0 green:0.631 blue:0.871 alpha:1]];
    _addButton.layer.borderColor=[UIColor whiteColor].CGColor;
    _addButton.layer.cornerRadius=5;
    
    
    //Setup clearButton design
    _clearButton.layer.borderWidth=2.0f;
    [_clearButton setBackgroundColor:[UIColor colorWithRed:0.878 green:0.322 blue:0.024 alpha:1]];
    _clearButton.layer.borderColor=[UIColor whiteColor].CGColor;
    _clearButton.layer.cornerRadius=5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addGeofence:(id)sender {
    GeofenceMonitor  * gfm = [GeofenceMonitor sharedObj];
    NSMutableDictionary * fence = [NSMutableDictionary new];
    [fence setValue:@"1" forKey:@"identifier"];
    [fence setValue:@"40.42895070705125" forKey:@"latitude"];
    [fence setValue:@"-86.92145791336877" forKey:@"longitude"];
    [fence setValue:@"500" forKey:@"radius"];
    
    if([gfm checkLocationManager])
    {
        [gfm addGeofence:fence];
        [gfm findCurrentFence];
    }
    
}

- (IBAction)clearGeofence:(id)sender {
    GeofenceMonitor  * gfm = [GeofenceMonitor sharedObj];
    
    [gfm clearGeofences];
}

@end
