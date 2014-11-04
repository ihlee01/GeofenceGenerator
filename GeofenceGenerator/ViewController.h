//
//  ViewController.h
//  GeofenceGenerator
//
//  Created by Eric Lee on 11/4/14.
//  Copyright (c) 2014 Eric Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
- (IBAction)addGeofence:(id)sender;
- (IBAction)clearGeofence:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) IBOutlet UIButton *clearButton;

@end

