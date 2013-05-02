//
//  NSData+Random.m
//  AS Logins
//
//  Created by Robbie Clarken on 2/05/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "NSData+Random.h"

@implementation NSData (Random)

+ (NSData *)randomDataOfLength:(NSUInteger)length {
    NSMutableData *data = [NSMutableData dataWithCapacity:length];
    for (NSUInteger i = 0; i < length; i++) {
        NSInteger randomBits = arc4random();
        [data appendBytes:(void *)&randomBits length:1];
    }
    return data;
}

@end
