//
//  Group.h
//  AS Logins
//
//  Created by Robbie Clarken on 15/04/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Device;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSNumber * uuid;
@property (nonatomic, retain) NSDate * modifiedDate;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSOrderedSet *devices;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)insertObject:(Device *)value inDevicesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromDevicesAtIndex:(NSUInteger)idx;
- (void)insertDevices:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeDevicesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInDevicesAtIndex:(NSUInteger)idx withObject:(Device *)value;
- (void)replaceDevicesAtIndexes:(NSIndexSet *)indexes withDevices:(NSArray *)values;
- (void)addDevicesObject:(Device *)value;
- (void)removeDevicesObject:(Device *)value;
- (void)addDevices:(NSOrderedSet *)values;
- (void)removeDevices:(NSOrderedSet *)values;
@end
