//
//  Group+Create.m
//  AS Logins
//
//  Created by Robbie Clarken on 22/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "Group+Create.h"
#import "ISODateFormatter.h"

static NSString *EntityName = @"Group";

@implementation Group (Create)

+ (Group *)groupWithUuid:(NSString *)uuid inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:EntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"uuid = %@", uuid];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    Group *group;
    if (error) {
        NSLog(@"Unresolved error in %s: %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
        abort();
    } else {
        if ([matches count] > 0) {
            group = (Group *)matches[0];
        } else {
            group = (Group *)[NSEntityDescription insertNewObjectForEntityForName:EntityName inManagedObjectContext:context];
        }
    }
    return group;
}

+ (Group *)groupWithName:(NSString *)name atPosition:(NSNumber *)position inContext:(NSManagedObjectContext *)context {
    Group *group;
    // TODO: Check if group exists with name already
    group = [NSEntityDescription insertNewObjectForEntityForName:EntityName inManagedObjectContext:context];
    group.name = name;
    group.position = position;
    group.lastModifiedDate = [NSDate date];
    group.uuid = [[NSProcessInfo processInfo] globallyUniqueString];
    group.toDelete = @NO;
    return group;
}

+ (Group *)syncGroupWithPropertyValues:(NSDictionary *)values inContext:(NSManagedObjectContext *)context {
    Group *group = [Group groupWithUuid:values[@"uuid"] inContext:context];
    NSLog(@"%@", group);
    [group updateWithPropertyValues:values];
    NSLog(@"%@", group);
    return group;
}

- (void)updateWithPropertyValues:(NSDictionary *)values {
    self.name = values[@"name"];
    self.position = values[@"position"];
    self.lastModifiedDate = [[[ISODateFormatter alloc] init] dateFromString:values[@"lastModifiedDate"]];
    self.uuid = values[@"uuid"];
    self.toDelete = values[@"toDelete"];
}

@end
