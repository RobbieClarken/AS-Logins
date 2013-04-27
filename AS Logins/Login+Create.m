//
//  Login+Create.m
//  AS Logins
//
//  Created by Robbie Clarken on 22/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "Login+Create.h"
#import "ISODateFormatter.h"

static NSString *EntityName = @"Login";

@implementation Login (Create)

+ (Login *)loginWithUuid:(NSString *)uuid inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:EntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"uuid = %@", uuid];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    Login *login;
    if (error) {
        NSLog(@"Unresolved error in %s: %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
        abort();
    } else {
        if ([matches count] > 0) {
            login = (Login *)matches[0];
        } else {
            login = (Login *)[NSEntityDescription insertNewObjectForEntityForName:EntityName inManagedObjectContext:context];
            login.uuid = uuid;
        }
    }
    return login;
}

+ (Login *)loginForDevice:(Device *)device inContext:(NSManagedObjectContext *)context {
    Login *login = [NSEntityDescription insertNewObjectForEntityForName:@"Login" inManagedObjectContext:context];
    login.device = device;
    login.createdDate = [NSDate date];
    login.lastModifiedDate = [NSDate date];
    login.uuid = [[NSProcessInfo processInfo] globallyUniqueString];
    login.toDelete = @NO;
    return login;
}

+ (Login *)syncLoginWithPropertyValues:(NSDictionary *)values inContext:(NSManagedObjectContext *)context {
    ISODateFormatter *dateFormatter = [[ISODateFormatter alloc] init];
    Login *login = [self loginWithUuid:values[@"uuid"] inContext:context];
    login.createdDate = [dateFormatter dateFromString:values[@"createdDate"]];
    login.lastModifiedDate = [dateFormatter dateFromString:values[@"lastModifiedDate"]];
    login.password = values[@"password"];
    login.toDelete = values[@"toDelete"];
    login.username = values[@"username"];
    login.device = [Device deviceWithUuid:values[@"device"] inContext:context];
    return login;
}

@end
