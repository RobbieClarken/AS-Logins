//
//  Login.h
//  AS Logins
//
//  Created by Robbie Clarken on 16/04/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Device;

@interface Login : NSManagedObject

@property (nonatomic, retain) NSDate * lastModifiedDate;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSNumber * toDelete;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) Device *device;

@end
