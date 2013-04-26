//
//  ISODateFormatter.m
//  AS Logins
//
//  Created by Robbie Clarken on 26/04/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "ISODateFormatter.h"

@implementation ISODateFormatter

- (id)init {
    self = [super init];
    if (self) {
        [self setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
        [self setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    }
    return self;
}

@end
