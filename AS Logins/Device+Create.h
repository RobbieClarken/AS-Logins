//
//  Device+Create.h
//  AS Logins
//
//  Created by Robbie Clarken on 15/04/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "Device.h"
#import "Group.h"

@interface Device (Create)

+ (Device *)deviceForGroup:(Group *)group inContext:(NSManagedObjectContext *)context;

@end
