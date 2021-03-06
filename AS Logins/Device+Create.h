//
//  Device+Create.h
//  AS Logins
//
//  Created by Robbie Clarken on 15/04/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "Device.h"
#import "Group+Create.h"

@interface Device (Create)

+ (Device *)deviceWithUuid:(NSString *)uuid inContext:(NSManagedObjectContext *)context;
+ (Device *)deviceForGroup:(Group *)group inContext:(NSManagedObjectContext *)context;
+ (Device *)syncDeviceWithPropertyValues:(NSDictionary *)values inContext:(NSManagedObjectContext *)context;
- (NSArray *)activeLogins;

@end
