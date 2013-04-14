//
//  Device+Create.m
//  AS Logins
//
//  Created by Robbie Clarken on 15/04/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "Device+Create.h"

@implementation Device (Create)

+ (Device *)deviceForGroup:(Group *)group inContext:(NSManagedObjectContext *)context {
    Device *device = [NSEntityDescription insertNewObjectForEntityForName:@"Device" inManagedObjectContext:context];
    device.group = group;
    device.modifiedDate = [NSDate date];
    device.uuid = [[NSProcessInfo processInfo] globallyUniqueString];
    device.deleted = NO;
    return device;
}

@end
