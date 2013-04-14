//
//  Group+Create.m
//  AS Logins
//
//  Created by Robbie Clarken on 22/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "Group+Create.h"

@implementation Group (Create)

+ (Group *)groupWithName:(NSString *)name atPosition:(NSNumber *)position inContext:(NSManagedObjectContext *)context {
    Group *group;
    // TODO: Check if group exists with name already
    group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:context];
    group.name = name;
    group.position = position;
    group.lastModifiedDate = [NSDate date];
    group.uuid = [[NSProcessInfo processInfo] globallyUniqueString];
    group.toDelete = @NO;
    return group;
}

@end
