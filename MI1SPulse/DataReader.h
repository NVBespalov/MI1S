//
//  DataReader.h
//  MI1SPulse
//
//  Created by Nick Bespalov on 02.07.16.
//  Copyright © 2016 Nick Bespalov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataReader : NSObject

@property (nonatomic) NSUInteger pos;
@property (nonatomic) Byte *bytes;
@property (nonatomic) NSUInteger length;

- (instancetype)initWithData:(NSData *)data;
- (instancetype)rePos:(NSUInteger)pos;
- (NSUInteger)bytesLeftCount;
- (NSUInteger)readInt:(NSUInteger)bytesCount;
- (NSUInteger)readIntReverse:(NSUInteger)bytesCount;
- (NSInteger)readSensorData;
- (NSString *)readString:(NSUInteger)bytesCount;
- (NSString *)readVersionString;
- (NSDate *)readDate;

@end
