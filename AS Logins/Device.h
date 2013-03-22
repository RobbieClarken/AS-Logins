//
//  Device.h
//  AS Logins
//
//  Created by Robbie Clarken on 22/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group, Login;

@interface Device : NSManagedObject

@property (nonatomic, retain) NSString * hostname;
@property (nonatomic, retain) NSString * ip;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) NSOrderedSet *logins;
@end

@interface Device (CoreDataGeneratedAccessors)

- (void)insertObject:(Login *)value inLoginsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLoginsAtIndex:(NSUInteger)idx;
- (void)insertLogins:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLoginsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLoginsAtIndex:(NSUInteger)idx withObject:(Login *)value;
- (void)replaceLoginsAtIndexes:(NSIndexSet *)indexes withLogins:(NSArray *)values;
- (void)addLoginsObject:(Login *)value;
- (void)removeLoginsObject:(Login *)value;
- (void)addLogins:(NSOrderedSet *)values;
- (void)removeLogins:(NSOrderedSet *)values;
@end
