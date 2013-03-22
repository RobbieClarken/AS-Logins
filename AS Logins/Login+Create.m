//
//  Login+Create.m
//  AS Logins
//
//  Created by Robbie Clarken on 22/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "Login+Create.h"

@implementation Login (Create)

+ (Login *)loginInContext:(NSManagedObjectContext *)context {
    Login *login = [NSEntityDescription insertNewObjectForEntityForName:@"Login" inManagedObjectContext:context];
    return login;
}

@end
