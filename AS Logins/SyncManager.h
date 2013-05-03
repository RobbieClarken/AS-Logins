//
//  SyncManager.h
//  AS Logins
//
//  Created by Robbie Clarken on 15/04/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SyncCompletionBlock)(BOOL success);

@interface SyncManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (SyncManager *)syncManagerForManagedObjectContext:(NSManagedObjectContext *)context;
- (void)syncWithCompetionBlock:(SyncCompletionBlock)completionBlock;

@end
