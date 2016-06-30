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
    // Scan for all available CoreBluetooth LE devices
//    NSArray *services = @[[CBUUID UUIDWithString:POLARH7_HRM_HEART_RATE_SERVICE_UUID], [CBUUID UUIDWithString:POLARH7_HRM_DEVICE_INFO_SERVICE_UUID]];
    CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.centralManager = centralManager;
}

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

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Connected to LE Device: %@ ", peripheral.name);
    [peripheral setDelegate:self];
    [peripheral discoverServices:@[[CBUUID UUIDWithString:@"180D"],[CBUUID UUIDWithString:@"FEE0"]]];
    self.connected = [NSString stringWithFormat:@"Connected: %@", peripheral.state == CBPeripheralStateConnected ? @"YES" : @"NO"];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in peripheral.services) {
        if([service.UUID isEqual:[CBUUID UUIDWithString:@"180D"]]){
            self.heartRateService = service;
            [peripheral discoverCharacteristics:nil forService:service];
            continue;
        }
        if([service.UUID isEqual:[CBUUID UUIDWithString:@"FEE0"]]){
            self.miliService = service;
            [peripheral discoverCharacteristics:nil forService:service];
            continue;
        }
        [peripheral discoverCharacteristics:nil forService:service];
        
    }
    

}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *aChar in service.characteristics) {
//        NSLog(@"Discovered char: %@ in service %@", aChar.UUID, service.UUID);
//        NSLog(@"------------------------------------------------------------");
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FF04"]]) {
            self.userInfoCharacteristic = aChar;
        }
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FF03"]]) {
            self.notificationCharacteristic = aChar;
        }
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]])  {
            self.heartRateCharacteristic = aChar;
        }
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A39"]])  {
            self.heartRateControlPointCharacteristic = aChar;
        }
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FF0C"]])  {
            self.battery = aChar;
            //[self.mi1S readValueForCharacteristic:aChar];
            
        }
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FF07"]])  {
            self.activityCharacteristic = aChar;
            //[self.mi1S readValueForCharacteristic:aChar];
            
        }
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FF06"]])  {
            self.stepsCharacteristic = aChar;
            //[self.mi1S readValueForCharacteristic:aChar];
            
        }
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A06"]])  {
            self.vibrateNotificationsCharacteristic = aChar;
            
        }
        
    }
    
    

//        NSLog(@"Discovered char: %@ in service %@", aChar.UUID, service.UUID);
//        NSLog(@"------------------------------------------------------------");
//        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FF0C"]])  {
//            [self.mi1S readValueForCharacteristic:aChar];
//            
//        }
//        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FF0E"]])  {
////            [self.mi1S readValueForCharacteristic:aChar];
//            [self.mi1S setNotifyValue:YES forCharacteristic:aChar];
//            
//        }
//        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FF01"]])  {
//            [self.mi1S readValueForCharacteristic:aChar];
//            
//        }
//        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FF02"]]) {
//            [self.mi1S readValueForCharacteristic:aChar];
//        }
//        
//        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FF04"]]) {
//            //CHAR_USER_INFO
////            unsigned int uid = 20271234;
////            unsigned int gender = 1;
////            unsigned int age = 32;
////            unsigned int height = 160;
////            unsigned int weight = 40;
////            char alias = 'J';
////            unsigned int type = 0;
////            unsigned char mac = 'C8:0F:10:32:5B:3C';
//            //unsigned char bytes1[] = {(uid & 0xff), (uid >> 8 & 0xff), (uid >> 16 & 0xff), (uid >> 24 & 0xff), gender, age, height, weight, type, 4, 0, alias, mac};
//            unsigned char bytes[] = {-126, 80, 53, 1, 1, 32, -96, 40, 0, 4, 0, 49, -27, -109, -120, -27, -109, -120, 0, 81};
//            NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
//            [self.mi1S setNotifyValue:YES forCharacteristic:aChar];
//            [self.mi1S writeValue:data forCharacteristic:aChar type:CBCharacteristicWriteWithoutResponse];
//            
//        }
//        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FF06"]]) {
//            [self.mi1S readValueForCharacteristic:aChar];
//        }
//        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FF05"]]) {
//            //enableSensorDataNotify
//            unsigned char bytes[] = {18, 1};
//            NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
//            [self.mi1S writeValue:data forCharacteristic:aChar type:CBCharacteristicWriteWithoutResponse];
//            [self.mi1S readValueForCharacteristic:aChar];
//        }
//        
//        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A39"]])  {
//            //HR Control point
//            [self.mi1S readValueForCharacteristic:aChar];
//            unsigned char bytes[] = {21, 2, 1};
//            NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
//            [self.mi1S writeValue:data forCharacteristic:aChar type:CBCharacteristicWriteWithoutResponse];
//        }
//        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A06"]])  {
//            [self.mi1S readValueForCharacteristic:aChar];
////            int i = 04;
////            [self.mi1S writeValue:[NSData dataWithBytes: &i length: sizeof(i)] forCharacteristic:aChar type:CBCharacteristicWriteWithoutResponse];
//        }
//    }
}
// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FF0C"]])  {
        NSData *data = [characteristic value];      // 1
        const uint8_t *reportData = [data bytes];
        NSLog(@"The battery power %d %%", reportData[0]);
        NSLog(@"The battery charged %d times", 0xffff & ((0xff & reportData[7]) | (0xff & reportData[8]) << 8));
        NSLog(@"The battery status is %d", reportData[9]);
        NSLog(@"Last charged %d/%d/%d %d:%d", reportData[1] + 2000, reportData[2], reportData[3], reportData[4], reportData[5]);
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FF02"]]) {
        NSData *data = [characteristic value];      // 1
        const uint8_t *reportData = [data bytes];
        NSLog(@"Device name is %@", [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]);
        
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FF04"]]) {
        NSData *data = [characteristic value];      // 1
        const uint8_t *reportData = [data bytes];
        //NSLog(@"UUID %d", reportData[3] << 24 | (reportData[2] & 0xFF) << 16 | (reportData[1] & 0xFF) << 8 | (reportData[0] & 0xFF));
        
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FF06"]]) {
        NSData *data = [characteristic value];      // 1
        const uint8_t *reportData = [data bytes];
        NSLog(@"Steps %u", (0xffff & ((0xff & reportData[0]) | (0xff & reportData[1]) << 8)));
        
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A39"]]) {
        //[self getHeartBPMData:characteristic error:error];
        
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FF05"]]) {
        //[self getHeartBPMData:characteristic error:error];
        NSData *data = [characteristic value];      // 1
        const uint8_t *reportData = [data bytes];
        
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
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FF0E"]]) {
        NSData *data = [characteristic value];      // 1
        const uint8_t *reportData = [data bytes];
    }
}
//- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
//    for(CBDescriptor *aCharDesc in characteristic.descriptors) {
//        NSLog(@"Enabling pulse real time notifications");
//        if([aCharDesc.UUID isEqual:[CBUUID UUIDWithString:@"2902"]]){
//            unsigned char bytes[] = {0x01, 0x00};
//            NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
//            [peripheral writeValue:data forDescriptor:aCharDesc];
//        }
//    }
//}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Disconnected from central");
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
}
- (IBAction)mesureHeartRate:(id)sender {
    unsigned char bytes[] = {21, 2, 1};
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    NSLog(@"Setting control point ");
    [self.mi1S writeValue:data forCharacteristic:self.heartRateControlPointCharacteristic type:CBCharacteristicWriteWithoutResponse];
}

- (IBAction)setUserinfo:(id)sender {
    //                unsigned int uid = 20271234;
    //                unsigned int gender = 1;
    //                unsigned int age = 32;
    //                unsigned int height = 160;
    //                unsigned int weight = 40;
    //                char alias = 'J';
    //                unsigned int type = 0;
    //                unsigned char mac = 'C8:0F:10:32:5B:3C';
    //unsigned char bytes1[] = {(uid & 0xff), (uid >> 8 & 0xff), (uid >> 16 & 0xff), (uid >> 24 & 0xff), gender, age, height, weight, type, 4, 0, alias, mac};
    unsigned char bytes[] = {-126, 80, 53, 1, 1, 32, -96, 40, 0, 4, 0, 49, -27, -109, -120, -27, -109, -120, 0, 81};
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    NSLog(@"Setting user info");
    [self.mi1S writeValue:data forCharacteristic:self.userInfoCharacteristic type:CBCharacteristicWriteWithoutResponse];

}

- (IBAction)vibrate:(id)sender {
    int i = 04;
    [self.mi1S writeValue:[NSData dataWithBytes: &i length: sizeof(i)] forCharacteristic:self.vibrateNotificationsCharacteristic type:CBCharacteristicWriteWithoutResponse];

}

- (IBAction)setNotifications:(id)sender {
     NSLog(@"Setting user info notifications");
    [self.mi1S setNotifyValue:YES forCharacteristic:self.heartRateCharacteristic];
    [self.mi1S setNotifyValue:YES forCharacteristic:self.activityCharacteristic];
    [self.mi1S setNotifyValue:YES forCharacteristic:self.stepsCharacteristic];
    [self.mi1S setNotifyValue:YES forCharacteristic:self.notificationCharacteristic];
}

- (IBAction)battery:(id)sender {
    [self.mi1S readValueForCharacteristic:self.battery];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
