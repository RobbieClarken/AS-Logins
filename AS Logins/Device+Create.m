//
//  Device+Create.m
//  AS Logins
//
//  Created by Robbie Clarken on 15/04/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "Device+Create.h"
#import "ISODateFormatter.h"

static NSString *EntityName = @"Device";

@implementation Device (Create)

+ (Device *)deviceWithUuid:(NSString *)uuid inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:EntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"uuid = %@", uuid];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    Device *device;
    if (error) {
        NSLog(@"Unresolved error in %s: %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
        abort();
    } else {
        if ([matches count] > 0) {
            device = (Device *)matches[0];
        } else {
            device = (Device *)[NSEntityDescription insertNewObjectForEntityForName:EntityName inManagedObjectContext:context];
            device.uuid = uuid;
        }
    }
    return device;
}

+ (Device *)deviceForGroup:(Group *)group inContext:(NSManagedObjectContext *)context {
    Device *device = [NSEntityDescription insertNewObjectForEntityForName:EntityName inManagedObjectContext:context];
    device.group = group;
    device.lastModifiedDate = [NSDate date];
    device.uuid = [[NSProcessInfo processInfo] globallyUniqueString];
    device.toDelete = @NO;
    return device;
}

+ (Device *)syncDeviceWithPropertyValues:(NSDictionary *)values inContext:(NSManagedObjectContext *)context {
    Device *device = [self deviceWithUuid:values[@"uuid"] inContext:context];
    device.hostname = values[@"hostname"];
    device.ip = values[@"ip"];
    device.lastModifiedDate = [[[ISODateFormatter alloc] init] dateFromString:values[@"lastModifiedDate"]];
    device.name = values[@"name"];
    device.toDelete = values[@"toDelete"];
    device.url = values[@"url"];
    device.group = [Group groupWithUuid:values[@"group"] inContext:context];
    return device;
}

@end
