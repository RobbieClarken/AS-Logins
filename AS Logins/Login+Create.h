//
//  Login+Create.h
//  AS Logins
//
//  Created by Robbie Clarken on 22/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "Login.h"
#import "Device.h"

@interface Login (Create)

+ (Login *)loginForDevice:(Device *)device inContext:(NSManagedObjectContext *)context;

@end
