//
//  BroadcastViewController.m
//  iBeacons
//
//  Created by Christopher Constable on 3/19/14.
//  Copyright (c) 2014 The Analog School. All rights reserved.
//

@import CoreLocation;
@import CoreBluetooth;

#import "BroadcastViewController.h"

@interface BroadcastViewController () <CBPeripheralManagerDelegate>

@property (strong, nonatomic) NSDictionary *beaconData;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

- (IBAction)rebroadcastButtonPressed:(id)sender;

@end

@implementation BroadcastViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                     queue:nil
                                                                   options:nil];
}

- (void)dealloc
{
    [self.peripheralManager stopAdvertising];
}

#pragma mark - Peripheral Manager

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager*)peripheral
{
    if (peripheral.state == CBPeripheralManagerStatePoweredOn)
    {
        NSLog(@"State: ON. Starting broadcasting...");
        self.statusLabel.text = @"Initializing...";
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:kBeaconDefaultUUID];
        CLBeaconRegion *myBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                                 major:[kBeaconDefaultMajor integerValue]
                                                                                 minor:[kBeaconDefaultMinor integerValue]
                                                                            identifier:kBeaconDefaultCompanyIdentifier];
        
        self.beaconData = [myBeaconRegion peripheralDataWithMeasuredPower:nil];
        NSLog(@"%@", self.beaconData);
        
        [self.peripheralManager startAdvertising:self.beaconData];
    }
    else if (peripheral.state == CBPeripheralManagerStatePoweredOff)
    {
        NSLog(@"State: OFF.");
        self.statusLabel.text = @"BLE Off";
        [self.peripheralManager stopAdvertising];
    }
    else if (peripheral.state == CBPeripheralManagerStateUnsupported)
    {
        NSLog(@"State: UNSUPPORTED.");
        self.statusLabel.text = @"Unsupported Device";
    }
    else if (peripheral.state == CBPeripheralManagerStateUnknown)
    {
        NSLog(@"State: UNKNOWN.");
        self.statusLabel.text = @"Unknown Device State";
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (!error) {
        NSLog(@"Started broadcasting.");
        self.statusLabel.text = @"Broadcasting...";
    }
    else {
        NSLog(@"Error %@ %@", [error localizedDescription], [error localizedFailureReason]);
        self.statusLabel.text = @"Error :(";
    }
}

#pragma mark - Actions

- (IBAction)rebroadcastButtonPressed:(id)sender {

}

@end
