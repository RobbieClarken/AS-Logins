//
//  Group+Create.h
//  AS Logins
//
//  Created by Robbie Clarken on 22/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "Group.h"

@interface Group (Create)

+ (Group *)groupWithName:(NSString *)name atPosition:(NSNumber *)position inContext:(NSManagedObjectContext *)context;
+ (Group *)syncGroupWithPropertyValues:(NSDictionary *)values inContext:(NSManagedObjectContext *)context;

@end
