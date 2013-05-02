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
#import "SiteSettings.h"

@interface SyncManager()

@property (strong, nonatomic) ISODateFormatter *dateFormatter;

@end

@implementation SyncManager

+ (SyncManager *)syncManagerForManagedObjectContext:(NSManagedObjectContext *)context {
    SyncManager *syncManager = [[SyncManager alloc] init];
    syncManager.managedObjectContext = context;
    return syncManager;
}

- (ISODateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[ISODateFormatter alloc] init];
    }
    return _dateFormatter;
}

- (void)updateChangesFromServer:(NSDictionary *)changes {
    [self.managedObjectContext performBlock:^{
        for (NSDictionary *changedGroupValues in changes[@"groups"]) {
            [Group syncGroupWithPropertyValues:changedGroupValues inContext:self.managedObjectContext];
        }
        for (NSDictionary *changedDeviceValues in changes[@"devices"]) {
            [Device syncDeviceWithPropertyValues:changedDeviceValues inContext:self.managedObjectContext];
        }
        for (NSDictionary *changedLoginValues in changes[@"logins"]) {
            [Login syncLoginWithPropertyValues:changedLoginValues inContext:self.managedObjectContext];
        }
        [self.managedObjectContext save:nil];
    }];
}

- (void)sync {
    static NSString *LastSyncDateKey = @"lastSyncDate";
    NSDate *lastSyncDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:LastSyncDateKey];
    if (!lastSyncDate) {
        lastSyncDate = [NSDate dateWithTimeIntervalSince1970:0.0f];
        [[NSUserDefaults standardUserDefaults] setObject:lastSyncDate forKey:LastSyncDateKey];
    }
    
    NSData *postData = [self JSONDataOfLocalChangesAfterDate:lastSyncDate];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kSyncServerURL]];
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
            return;
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:LastSyncDateKey];
        [self updateChangesFromServer:changes];
    }];
}

- (NSData *)JSONDataOfLocalChangesAfterDate:(NSDate *)date {
    NSMutableDictionary *dictionaryForJSON = [NSMutableDictionary dictionary];
    NSMutableDictionary *changesDictionaryForJSON = [NSMutableDictionary dictionary];
    
    NSArray *changedGroups = [self objectsWithEntityName:@"Group" modifiedAfterDate:date];
    NSArray *changedGroupsForJSON = [self changedObjectsForJSONFromArray:changedGroups forKeys:@[@"uuid", @"lastModifiedDate", @"toDelete", @"name", @"position"]];
    
    NSArray *changedDevices = [self objectsWithEntityName:@"Device" modifiedAfterDate:date];
    NSArray *changedDevicesForJSON = [self changedObjectsForJSONFromArray:changedDevices forKeys:@[@"uuid", @"lastModifiedDate", @"toDelete", @"name", @"hostname", @"ip", @"url", @"group"]];
    
    NSArray *changedLogins = [self objectsWithEntityName:@"Login" modifiedAfterDate:date];
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

- (NSArray *)objectsWithEntityName:(NSString *)entityName modifiedAfterDate:(NSDate *)date {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.predicate = [NSPredicate predicateWithFormat:@"lastModifiedDate > %@", date];
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:nil];
    return results;
}

- (NSString *)formatAsISODate:(NSDate *)date {
    return [self.dateFormatter stringFromDate:date];
}

@end
