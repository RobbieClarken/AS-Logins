//
//  Group+Create.h
//  AS Logins
//
//  Created by Robbie Clarken on 22/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "Group.h"

@interface Group (Create)

+ (Group *)groupWithName:(NSString *)name inContext:(NSManagedObjectContext *)context;

@end