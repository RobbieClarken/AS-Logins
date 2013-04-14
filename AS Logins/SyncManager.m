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
    NSLog(@"%s %@", __PRETTY_FUNCTION__, lastSyncDate);
    if (!lastSyncDate) {
        lastSyncDate = [NSDate dateWithTimeIntervalSince1970:0.0f];
        [[NSUserDefaults standardUserDefaults] setObject:lastSyncDate forKey:LastSyncDateKey];
    }
}

- (NSArray *)groupsModifiedAfterDate:(NSDate *)date {
    return @[];
}

- (NSArray *)devicesModifiedAfterDate:(NSDate *)date {
    return @[];
}

- (NSArray *)loginsModifiedAfterDate:(NSDate *)date {
    return @[];
}

@end
