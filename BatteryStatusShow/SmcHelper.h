//
//  SmcHelper.h
//  HWMonitor
//
//  Created by Kozlek on 28/11/13.
//  Copyright (c) 2013 kozlek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "smc.h"

#define bit_get(p,m) ((p) & (m))
#define bit_set(p,m) ((p) |= (m))
#define bit_clear(p,m) ((p) &= ~(m))
#define bit_flip(p,m) ((p) ^= (m))
#define bit_write(c,p,m) (c ? bit_set(p,m) : bit_clear(p,m))
#define BIT(x)    (0x01 << (x))
#define LONGBIT(x) ((unsigned long)0x00000001 << (x))

//#define ABS(x) ((x) >= 0 ? (x) : -(x))
#define SGN(x) ((x) > 0 ? 1.0 : -1.0)
#define ROUND(x) ((x) + 0.5 > int(x) + 1 ? int(x) + 1 : int(x))
#define ROUND50(x) (((int)((x) + 25) / 50) * 50)

@interface SmcHelper : NSObject

+ (int)getIndexFromHexChar:(char)c;
+ (BOOL)isValidIntegerSmcType:(NSString *)type;
+ (BOOL)isValidFloatingSmcType:(NSString *)type;
+ (NSNumber*)decodeNumericValueFromBuffer:(void*)data length:(NSUInteger)length type:(const char *)type;
+ (BOOL)encodeNumericValue:(NSNumber*)value length:(NSUInteger)length type:(const char *)type outBuffer:(void*)outBuffer;

+ (NSNumber*)readNumericKey:(NSString*)key connection:(io_connect_t)connection;
+ (BOOL)writeNumericKey:(NSString*)key value:(NSNumber*)value connection:(io_connect_t)connection;

@end
