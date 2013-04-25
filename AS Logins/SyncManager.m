//
//  SyncManager.m
//  AS Logins
//
//  Created by Robbie Clarken on 15/04/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "SyncManager.h"
#import "Group+Create.h"

@implementation SyncManager

+ (SyncManager *)sharedSyncManager {
    static SyncManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SyncManager alloc] init];
    });
    return manager;
}

- (void)syncManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    static NSString *LastSyncDateKey = @"lastSyncDate";
    NSDate *lastSyncDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:LastSyncDateKey];
    if (!lastSyncDate) {
        lastSyncDate = [NSDate dateWithTimeIntervalSince1970:0.0f];
        [[NSUserDefaults standardUserDefaults] setObject:lastSyncDate forKey:LastSyncDateKey];
    }
    NSData *data = [self JSONDataOfLocalChangesAfterDate:lastSyncDate inManagedObjectContext:managedObjectContext];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", jsonString);
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:LastSyncDateKey];
}

- (NSData *)JSONDataOfLocalChangesAfterDate:(NSDate *)date inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableDictionary *dictionaryForJSON = [NSMutableDictionary dictionary];
    NSMutableDictionary *changesDictionaryForJSON = [NSMutableDictionary dictionary];
    
    NSArray *changedGroups = [self objectsWithEntityName:@"Group" modifiedAfterDate:date inManagedObjectContext:context];
    NSArray *changedGroupsForJSON = [self changedObjectsForJSONFromArray:changedGroups forKeys:@[@"uuid", @"lastModifiedDate", @"toDelete", @"name", @"position"]];
    
    NSArray *changedDevices = [self objectsWithEntityName:@"Device" modifiedAfterDate:date inManagedObjectContext:context];
    NSArray *changedDevicesForJSON = [self changedObjectsForJSONFromArray:changedDevices forKeys:@[@"uuid", @"lastModifiedDate", @"toDelete", @"name", @"hostname", @"ip", @"url", @"group"]];
    
    NSArray *changedLogins = [self objectsWithEntityName:@"Login" modifiedAfterDate:date inManagedObjectContext:context];
    NSArray *changedLoginForJSON = [self changedObjectsForJSONFromArray:changedLogins forKeys:@[@"uuid", @"lastModifiedDate", @"toDelete", @"username", @"password", @"createdDate", @"device"]];
    
    [changesDictionaryForJSON setValue:changedGroupsForJSON forKey:@"groups"];
    [changesDictionaryForJSON setValue:changedDevicesForJSON forKey:@"devices"];
    [changesDictionaryForJSON setValue:changedLoginForJSON forKey:@"logins"];
    
    [dictionaryForJSON setValue:changesDictionaryForJSON forKey:@"changes"];
    [dictionaryForJSON setValue:[self formatAsISODate:date] forKey:@"lastSyncDate"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionaryForJSON options:kNilOptions error:nil];
    return jsonData;
}

- (NSArray *)changedObjectsForJSONFromArray:(NSArray *)array forKeys:(NSArray *)keys {
    NSMutableArray *changedObjectsForJSON = [NSMutableArray arrayWithCapacity:[array count]];
    for (NSManagedObject *object in array) {
        NSMutableDictionary *dictionaryForJSON = [NSMutableDictionary dictionaryWithCapacity:[keys count]];
        for (NSString *key in keys) {
            NSObject *value = [object valueForKey:key];
            if ([value isKindOfClass:[NSDate class]]) {
                value = [self formatAsISODate:(NSDate *)value];
            } else if ([value isKindOfClass:[NSManagedObject class]]) {
                value = [value valueForKey:@"uuid"];
            }
            [dictionaryForJSON setValue:value forKey:key];
        }
        [changedObjectsForJSON addObject:dictionaryForJSON];
    }
    return changedObjectsForJSON;
}

- (NSArray *)objectsWithEntityName:(NSString *)entityName modifiedAfterDate:(NSDate *)date inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.predicate = [NSPredicate predicateWithFormat:@"lastModifiedDate > %@", date];
    NSArray *results = [context executeFetchRequest:request error:nil];
    return results;
}

- (NSString *)formatAsISODate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    return [formatter stringFromDate:date];
}

@end
