//
//  DataBuilder.h
//  MI1SPulse
//
//  Created by Nick Bespalov on 02.07.16.
//  Copyright © 2016 Nick Bespalov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataBuilder : NSObject
@property (nonatomic) NSUInteger pos;
@property (nonatomic) Byte *bytes;

- (instancetype)writeInt:(NSUInteger)value bytesCount:(NSUInteger)count;
- (instancetype)writeString:(NSString *)value bytesCount:(NSUInteger)count;
- (instancetype)writeVersionString:(NSString *)value;
- (instancetype)writeDate:(NSDate *)value;
- (instancetype)writeColorWithRed:(NSUInteger)red green:(NSUInteger)green blue:(NSUInteger)blue blink:(BOOL)blink;
- (instancetype)writeChecksumFromIndex:(NSUInteger)index length:(NSUInteger)length lastMACByte:(NSUInteger)lastMACByte;
- (NSData *)data;
@end
