//
//  ViewController.m
//  MI1SPulse
//
//  Created by Nick Bespalov on 27.06.16.
//  Copyright © 2016 Nick Bespalov. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.mi1SDeviceData = nil;
    
    // Clear out textView
    [self.deviceInfo setText:@""];
    
    // Create our Heart Rate BPM Label
    self.heartRateBPM = [[UILabel alloc] initWithFrame:CGRectMake(55, 30, 75, 50)];
    [self.heartRateBPM setTextColor:[UIColor whiteColor]];
    [self.heartRateBPM setText:[NSString stringWithFormat:@"%i", 0]];
    
    
    // Scan for all available CoreBluetooth LE devices
//    NSArray *services = @[[CBUUID UUIDWithString:POLARH7_HRM_HEART_RATE_SERVICE_UUID], [CBUUID UUIDWithString:POLARH7_HRM_DEVICE_INFO_SERVICE_UUID]];
    
    CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.centralManager = centralManager;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// method called whenever the device state changes.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    // Determine the state of the peripheral
    if ([central state] == CBCentralManagerStatePoweredOff) {
        NSLog(@"CoreBluetooth BLE hardware is powered off");
    }
    else if ([central state] == CBCentralManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
    else if ([central state] == CBCentralManagerStateUnauthorized) {
        NSLog(@"CoreBluetooth BLE state is unauthorized");
    }
    else if ([central state] == CBCentralManagerStateUnknown) {
        NSLog(@"CoreBluetooth BLE state is unknown");
    }
    else if ([central state] == CBCentralManagerStateUnsupported) {
        NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
    }
}
// CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if ([localName isEqual:@"MI1S"]) {
        NSLog(@"Found the LE Device: %@ ", peripheral.name);
        [self.centralManager stopScan];
        self.mi1S = peripheral;
        peripheral.delegate = self;
        NSLog(@"Connecting to the LE Device: %@ ", peripheral.name);
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}
// method called whenever we have successfully connected to the BLE peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Connected to LE Device: %@ ", peripheral.name);
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    self.connected = [NSString stringWithFormat:@"Connected: %@", peripheral.state == CBPeripheralStateConnected ? @"YES" : @"NO"];
}
// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in peripheral.services) {
        
        [peripheral discoverCharacteristics:nil forService:service];
    }
}
// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
    for (CBCharacteristic *aChar in service.characteristics) {
//        NSLog(@"Discovered char: %@ in service %@", aChar.UUID, service.UUID);
//        NSLog(@"------------------------------------------------------------");
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FF0C"]])  {
            [self.mi1S readValueForCharacteristic:aChar];
            
        }
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FF01"]])  {
            [self.mi1S readValueForCharacteristic:aChar];
            
        }
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FF02"]]) {
            [self.mi1S readValueForCharacteristic:aChar];
        }
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FF06"]]) {
            [self.mi1S readValueForCharacteristic:aChar];
        }
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]])  {
            [self.mi1S setNotifyValue:YES forCharacteristic:aChar];
        }
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A39"]])  {
            [self.mi1S readValueForCharacteristic:aChar];
        }
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A06"]])  {
            [self.mi1S readValueForCharacteristic:aChar];
            //int i = 01;
            //[self.mi1S writeValue:[NSData dataWithBytes: &i length: sizeof(i)] forCharacteristic:aChar type:CBCharacteristicWriteWithoutResponse];
        }
    }
}
// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FF0C"]])  {
        NSData *data = [characteristic value];      // 1
        const uint8_t *reportData = [data bytes];
        NSLog(@"The battery power %d %%", reportData[0]);
        NSLog(@"The battery charged %d times", (0xffff & ((0xff & reportData[7]) | (0xff & reportData[8]) << 8)));
        NSLog(@"The battery status is %d", reportData[9]);
        NSLog(@"Last charged %d/%d/%d %d:%d", reportData[1] + 2000, reportData[2], reportData[3], reportData[4], reportData[5]);
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FF02"]]) {
        NSData *data = [characteristic value];      // 1
        const uint8_t *reportData = [data bytes];
        NSLog(@"Device name is %@", [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]);
        
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FF06"]]) {
        NSData *data = [characteristic value];      // 1
        const uint8_t *reportData = [data bytes];
        NSLog(@"Steps %u", (0xffff & ((0xff & reportData[0]) | (0xff & reportData[1]) << 8)));
        
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A39"]]) {
        NSData *data = [characteristic value];      // 1
        const uint8_t *reportData = [data bytes];
        NSLog(@"Control point %u", reportData[1]);
        
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]]) {
        NSData *data = [characteristic value];      // 1
        const uint8_t *reportData = [data bytes];
        NSLog(@"Pulse %u", (0xffff & ((0xff & reportData[0]) | (0xff & reportData[1]) << 8)));
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A06"]]) {
        NSData *data = [characteristic value];      // 1
//        const uint8_t *reportData = [data bytes];
//        NSLog(@"vibrate %u", (0xffff & (0xff & reportData[0])));
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FF01"]]) {
        NSData *data = [characteristic value];      // 1
        const uint8_t *reportData = [data bytes];
        
        NSLog(@"base firmware version %u.%u.%u.%u", reportData[13], reportData[14], reportData[15], reportData[16]);
    }
}
@end
