//
//  Helper.h
//  MI1SPulse
//
//  Created by Nick Bespalov on 02.07.16.
//  Copyright © 2016 Nick Bespalov. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef void (^MBCounter)();

@interface Helper : NSObject

+ (NSUInteger)hexString2Int:(NSString *)value;
+ (NSString *)byte2HexString:(Byte)value;
+ (NSUInteger)CRC8WithBytes:(Byte *)bytes length:(NSUInteger)length;
+ (MBCounter)counter:(NSUInteger)count withBlock:(void (^)())counterCallback;

@end
