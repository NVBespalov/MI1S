//
//  ViewController.h
//  MI1SPulse
//
//  Created by Nick Bespalov on 27.06.16.
//  Copyright © 2016 Nick Bespalov. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral     *mi1S;
@property (nonatomic, strong) CBService *heartRateService;
@property (nonatomic, strong) CBService *miliService;
@property (nonatomic, strong) CBCharacteristic *battery;
@property (nonatomic, strong) CBCharacteristic *heartRateCharacteristic;
@property (nonatomic, strong) CBCharacteristic *heartRateControlPointCharacteristic;
@property (nonatomic, strong) CBCharacteristic *userInfoCharacteristic;
@property (nonatomic, strong) CBCharacteristic *activityCharacteristic;
@property (nonatomic, strong) CBCharacteristic *stepsCharacteristic;
@property (nonatomic, strong) CBCharacteristic *notificationCharacteristic;
@property (nonatomic, strong) CBCharacteristic *vibrateNotificationsCharacteristic;
// Properties to hold data characteristics for the peripheral device
@property (nonatomic, strong) NSString   *connected;
@property (nonatomic, strong) NSString   *bodyData;
@property (nonatomic, strong) NSString   *manufacturer;
@property (nonatomic, strong) NSString   *mi1SDeviceData;
@property (assign) uint16_t heartRate;

// Properties to handle storing the BPM and heart beat
@property (nonatomic, strong) UILabel    *heartRateBPM;
@property (nonatomic, retain) NSTimer    *pulseTimer;
- (void) getHeartBPMData:(CBCharacteristic *)characteristic error:(NSError *)error;
- (IBAction)setUserinfo:(id)sender;
- (IBAction)vibrate:(id)sender;
- (IBAction)setNotifications:(id)sender;
- (IBAction)battery:(id)sender;
@end

