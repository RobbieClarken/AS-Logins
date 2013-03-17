//
//  Device.h
//  AS Logins
//
//  Created by Robbie Clarken on 18/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group, Login;

@interface Device : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * hostname;
@property (nonatomic, retain) NSString * ip;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) NSSet *logins;
@end

@interface Device (CoreDataGeneratedAccessors)

- (void)addLoginsObject:(Login *)value;
- (void)removeLoginsObject:(Login *)value;
- (void)addLogins:(NSSet *)values;
- (void)removeLogins:(NSSet *)values;

@end
