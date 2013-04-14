//
//  Login+Create.m
//  AS Logins
//
//  Created by Robbie Clarken on 22/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "Login+Create.h"

@implementation Login (Create)

+ (Login *)loginForDevice:(Device *)device inContext:(NSManagedObjectContext *)context {
    Login *login = [NSEntityDescription insertNewObjectForEntityForName:@"Login" inManagedObjectContext:context];
    login.device = device;
    login.modifiedDate = [NSDate date];
    login.uuid = [[NSProcessInfo processInfo] globallyUniqueString];
    login.deleted = @NO;
    return login;
}

@end
