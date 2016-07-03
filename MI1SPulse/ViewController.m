//
//  ViewController.m
//  MI1SPulse
//
//  Created by Nick Bespalov on 27.06.16.
//  Copyright © 2016 Nick Bespalov. All rights reserved.
//

#import "ViewController.h"
#import "DataReader.h"
#import "DataBuilder.h"
#import "Helper.h"

@interface ViewController ()
typedef NS_ENUM(NSUInteger, GenderType) {
    GenderTypeFemale = 0,
    GenderTypeMale
};

typedef NS_ENUM(NSUInteger, AuthType) {
    AuthTypeNormal = 0,
    AuthTypeClearData,
    AuthTypeRetainData
};

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
        NSLog(@"Trying to connecting to the LE Device: %@ ", peripheral.name);
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Successfuly connected to LE Device: %@ ", peripheral.name);
    [peripheral setDelegate:self];
    [peripheral discoverServices:@[[CBUUID UUIDWithString:@"180D"],[CBUUID UUIDWithString:@"FEE0"]]];
    self.connected = [NSString stringWithFormat:@"Connected: %@", peripheral.state == CBPeripheralStateConnected ? @"YES" : @"NO"];
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Did not connected to LE Device: %@ ", peripheral.name);
    NSLog(@"%@", error);
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if([service.UUID isEqual:[CBUUID UUIDWithString:@"180D"]]){
        for (CBCharacteristic *aChar in service.characteristics){
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]])  {
                self.heartRateCharacteristic = aChar;
                [self.mi1S setNotifyValue:YES forCharacteristic:self.heartRateCharacteristic];
            } else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A39"]])  {
                self.heartRateControlPointCharacteristic = aChar;
            }
        }
    }
    if([service.UUID isEqual:[CBUUID UUIDWithString:@"1802"]]){
        for (CBCharacteristic *aChar in service.characteristics){ }
        
    }
    if([service.UUID isEqual:[CBUUID UUIDWithString:@"FEE0"]]){
        self.miliService = service;
        for (CBCharacteristic *aChar in service.characteristics){
            if([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FF01"]]) {
                self.deviceInfoCharacteristic = aChar;
            } else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FF04"]]) {
                self.userInfoCharacteristic = aChar;
            } else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FF03"]]) {
                self.notificationCharacteristic = aChar;
            } else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FF0C"]])  {
                self.battery = aChar;
            } else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FF07"]])  {
                self.activityCharacteristic = aChar;
                
            } else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FF06"]])  {
                self.stepsCharacteristic = aChar;
                
            } else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FF05"]])  {
                DataBuilder *builder = [[DataBuilder alloc] init];
                [builder writeInt:9 bytesCount:1];
                //[self.mi1S writeValue:builder.data forCharacteristic:self.vibrateNotificationsCharacteristic type:CBCharacteristicWriteWithoutResponse];
                
            }
        }
    }
    
}
// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FF0C"]])  {
        // 1
        DataReader *reader = [[DataReader alloc] initWithData:characteristic.value];
        NSUInteger level = [reader readInt:1];
        NSDate *lastCharge = [reader readDate];
        NSUInteger chargesCount = [reader readInt:2];
        NSUInteger status = [reader readInt:1];
        NSLog(@"--------Battery Info--------");
        NSLog(@"level = %tu%%, lastCharge = %@, chargesCount = %tu, status = %tx", level, lastCharge, chargesCount, status);
        NSLog(@"--------Battery Info--------");
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FF02"]]) {
        NSData *data = [characteristic value];      // 1
        const uint8_t *reportData = [data bytes];
        NSLog(@"Device name is %@", [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]);
        
    }
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FF04"]]) {
        NSData *data = [characteristic value];
        if (!data.length || error) {
            NSLog(@"No user data to show");
            return;
        }
        DataReader *reader = [[DataReader alloc] initWithData:data];
        NSUInteger uid = [reader readInt:4];
        NSUInteger gender = (GenderType)[reader readInt:1];
        NSUInteger  age = [reader readInt:1];
        NSUInteger height = [reader readInt:1];
        NSUInteger weight = [reader readInt:1];
        NSUInteger type = [reader readInt:1];
        NSString *alias = [reader readString:8];
        NSLog(@"--------User Info--------");
        NSLog(@"uid = %tu, gender = %tu, age = %tu, height = %tu cm, weight = %tu kg, alias = %@, type = %tu", uid, gender, age, height, weight, alias, type);
        NSLog(@"--------User Info--------");
        
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
        DataReader *reader = [[DataReader alloc] initWithData:characteristic.value];
        NSString *deviceID = @"";
        for (NSUInteger i = 0; i < 8; i++) {
            Byte byte = [reader readInt:1];
            deviceID = [deviceID stringByAppendingString:[Helper byte2HexString:byte]];
        }
        NSUInteger mac = [[reader rePos:3] readInt:1];
        NSUInteger mac16 = [[reader rePos:2] readIntReverse:2];
        NSUInteger appearence = [[reader rePos:6] readInt:1];
        NSUInteger feature = [reader readInt:1];
        
        NSString *profileVersion = [reader readVersionString];
        NSString *firmwareVersion = [reader readVersionString];
        NSLog(@"--------Device Info--------");
        NSLog(@"deviceID = %@, feature = %tu, appearence = %tu,  profileVersion = %@, firmwareVersion = %@, mac = %tu, mac16 = %tu>", deviceID, feature, appearence, profileVersion, firmwareVersion, mac, mac16);
        NSLog(@"--------Device Info--------");
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FF0E"]]) {
        NSData *data = [characteristic value];      // 1
        const uint8_t *reportData = [data bytes];
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Disconnected from central");
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
}
- (IBAction)mesureHeartRate:(id)sender {
    const unsigned char bytes[] = {0x15, 0x00, 0x00};
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    NSLog(@"Reseting control point ");
    [self.mi1S writeValue:data forCharacteristic:self.heartRateControlPointCharacteristic type:CBCharacteristicWriteWithResponse];
    DataBuilder *builder = [[DataBuilder alloc] init];
    [builder writeInt:21 bytesCount:1];
    [builder writeInt:2 bytesCount:1];
    [builder writeInt:1 bytesCount:1];
    const unsigned char bytes1[] = {15, 02, 01};
    NSData *data1 = [NSData dataWithBytes:bytes1 length:sizeof(bytes1)];
    NSLog(@"Setting control point to left hand");
    [self.mi1S writeValue:builder.data forCharacteristic:self.heartRateControlPointCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (IBAction)setUserinfo:(id)sender {
    DataBuilder *builder = [[DataBuilder alloc] init];
    NSUInteger uid = 20271234;
    GenderType gender = GenderTypeMale;
    NSUInteger age = 32;
    NSUInteger height = 160;
    NSUInteger weight = 40;
    NSString *alias = @"Arhi";
    AuthType type = AuthTypeNormal;
    [builder writeInt:uid bytesCount:4];
    [builder writeInt:gender bytesCount:1];
    [builder writeInt:age bytesCount:1];
    [builder writeInt:height bytesCount:1];
    [builder writeInt:weight bytesCount:1];
    [builder writeInt:type bytesCount:1];
    [builder writeString:alias bytesCount:10];
    [builder writeChecksumFromIndex:0 length:19 lastMACByte:0x81];
    
    [self.mi1S writeValue: builder.data forCharacteristic:self.userInfoCharacteristic type:CBCharacteristicWriteWithResponse];
    [self.mi1S readValueForCharacteristic:self.userInfoCharacteristic];
    
}
+ (NSUInteger)CRC8WithBytes:(Byte*)bytes length:(NSUInteger)length {
    NSUInteger checksum = 0;
    for (NSUInteger i = 0; i < length; i++) {
        checksum ^= bytes[i];
        for (NSUInteger j = 0; j < 8; j++) {
            if (checksum & 0x1) {
                checksum = (0x8c ^ (0xff & checksum >> 1));
            } else {
                checksum = (0xff & checksum >> 1);
            }
        }
    }
    return checksum;
}

- (IBAction)getDeviceInfo:(id)sender {
    [self.mi1S readValueForCharacteristic:self.deviceInfoCharacteristic];
}
- (IBAction)vibrate:(id)sender {
    int i = 04;
    [self.mi1S writeValue:[NSData dataWithBytes: &i length: sizeof(i)] forCharacteristic:self.vibrateNotificationsCharacteristic type:CBCharacteristicWriteWithoutResponse];
    
}

- (IBAction)setNotifications:(id)sender {
    NSLog(@"Setting user info notifications");
    [self.mi1S setNotifyValue:YES forCharacteristic:self.heartRateCharacteristic];
//    [self.mi1S setNotifyValue:YES forCharacteristic:self.activityCharacteristic];
//    [self.mi1S setNotifyValue:YES forCharacteristic:self.stepsCharacteristic];
//    [self.mi1S setNotifyValue:YES forCharacteristic:self.notificationCharacteristic];
    
}

- (IBAction)battery:(id)sender {
    [self.mi1S readValueForCharacteristic:self.battery];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
