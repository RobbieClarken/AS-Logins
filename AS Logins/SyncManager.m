//
//  SyncManager.m
//  AS Logins
//
//  Created by Robbie Clarken on 15/04/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "SyncManager.h"
#import "Group+Create.h"
#import "Device+Create.h"
#import "Login+Create.h"
#import "ISODateFormatter.h"

#define kURLString @"http://localhost:5051"

@interface SyncManager()

@property (strong, nonatomic) ISODateFormatter *dateFormatter;

@end

@implementation SyncManager

+ (SyncManager *)sharedSyncManager {
    static SyncManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SyncManager alloc] init];
    });
    return manager;
}

- (ISODateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[ISODateFormatter alloc] init];
    }
    return _dateFormatter;
}

- (void)updateChangesFromServer:(NSDictionary *)changes inContext:(NSManagedObjectContext *)context{    
    for (NSDictionary *changedGroupValues in changes[@"groups"]) {
        [Group syncGroupWithPropertyValues:changedGroupValues inContext:context];
    }
    for (NSDictionary *changedDeviceValues in changes[@"devices"]) {
        [Device syncDeviceWithPropertyValues:changedDeviceValues inContext:context];
    }
    for (NSDictionary *changedLoginValues in changes[@"logins"]) {
        [Login syncLoginWithPropertyValues:changedLoginValues inContext:context];
    }
    [context save:nil];
}

- (void)syncManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    static NSString *LastSyncDateKey = @"lastSyncDate";
    NSDate *lastSyncDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:LastSyncDateKey];
    if (!lastSyncDate) {
        lastSyncDate = [NSDate dateWithTimeIntervalSince1970:0.0f];
        [[NSUserDefaults standardUserDefaults] setObject:lastSyncDate forKey:LastSyncDateKey];
    }
    
    NSData *postData = [self JSONDataOfLocalChangesAfterDate:lastSyncDate inManagedObjectContext:managedObjectContext];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kURLString]];
    request.HTTPMethod = @"POST";
    [request setValue:[NSString stringWithFormat:@"%i", [postData length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = postData;
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSLog(@"Unresolved error in %s: %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
            return;
        }
        NSDictionary *changes = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error) {
            NSLog(@"Unresolved error in %s: %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
            abort();
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:LastSyncDateKey];
            [self updateChangesFromServer:changes inContext:managedObjectContext];
        });
    }];
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
    return [self.dateFormatter stringFromDate:date];
}

@end
