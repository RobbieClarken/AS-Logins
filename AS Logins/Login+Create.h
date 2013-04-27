//
//  Login+Create.h
//  AS Logins
//
//  Created by Robbie Clarken on 22/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "Login.h"
#import "Device+Create.h"

@interface Login (Create)

+ (Login *)loginWithUuid:(NSString *)uuid inContext:(NSManagedObjectContext *)context;
+ (Login *)loginForDevice:(Device *)device inContext:(NSManagedObjectContext *)context;
+ (Login *)syncLoginWithPropertyValues:(NSDictionary *)values inContext:(NSManagedObjectContext *)context;

@end
