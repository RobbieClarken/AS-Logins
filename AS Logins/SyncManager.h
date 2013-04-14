//
//  SyncManager.h
//  AS Logins
//
//  Created by Robbie Clarken on 15/04/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SyncManager : NSObject

+ (SyncManager *)sharedSyncManager;
- (void)syncManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

@end
