//
//  ScanViewController.m
//  iBeacons
//
//  Created by Christopher Constable on 3/19/14.
//  Copyright (c) 2014 The Analog School. All rights reserved.
//

#import "ScanViewController.h"

@import CoreLocation;

@interface ScanViewController () <CLLocationManagerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UITextField *uuidTextField;
@property (weak, nonatomic) IBOutlet UITextField *majorTextField;
@property (weak, nonatomic) IBOutlet UITextField *minorTextField;
@property (weak, nonatomic) IBOutlet UITextField *companyIdTextField;

- (IBAction)rescanButtonPressed:(id)sender;

@end

@implementation ScanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.uuidTextField.text = kBeaconDefaultUUID;
    self.companyIdTextField.text = kBeaconDefaultCompanyIdentifier;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:tapGesture];
	
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self rescanButtonPressed:self];
}

#pragma mark - Location Manager

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    self.statusLabel.text = @"Error :(";
}

- (void)locationManager:(CLLocationManager*)manager didEnterRegion:(CLRegion*)region
{
    NSLog(@"Did enter region: %@", region);
    self.statusLabel.text = @"Entered Region";
}

-(void)locationManager:(CLLocationManager*)manager didExitRegion:(CLRegion*)region
{
    NSLog(@"Did exit region: %@", region);
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    self.statusLabel.text = @"Exited Region";
}

-(void)locationManager:(CLLocationManager*)manager
       didRangeBeacons:(NSArray*)beacons
              inRegion:(CLBeaconRegion*)region
{
    if (beacons.count) {
        NSLog(@"Did range beacons: %@ in region: %@", beacons, region);
        CLBeacon *foundBeacon = [beacons firstObject];
        NSString *displayString = @"Beacon found: ";
        if (foundBeacon.proximity == CLProximityUnknown) {
            displayString = [displayString stringByAppendingString:@"Unknown"];
        }
        else if (foundBeacon.proximity == CLProximityFar) {
            displayString = [displayString stringByAppendingString:@"Far"];
        }
        else if (foundBeacon.proximity == CLProximityNear) {
            displayString = [displayString stringByAppendingString:@"Near"];
        }
        else if (foundBeacon.proximity == CLProximityImmediate) {
            displayString = [displayString stringByAppendingString:@"Immediate"];
        }
        self.statusLabel.text = displayString;
    }
    else {
        NSLog(@"No beacons found.");
        self.statusLabel.text = @"Scanning...";
    }
}

#pragma mark - Text Field

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return NO;
}

#pragma mark - Actions

- (void)dismissKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)rescanButtonPressed:(id)sender {
    self.statusLabel.text = @"Scanning...";
    
    // Stop ranging any beacons we previously were...
    if (self.beaconRegion) {
        [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    }
    
    // Start ranging new beacon...
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:self.uuidTextField.text];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                           identifier:self.companyIdTextField.text];
    
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    NSLog(@"Started ranging beacons.");
}

@end
