//
//  Login.h
//  AS Logins
//
//  Created by Robbie Clarken on 22/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Device;

@interface Login : NSManagedObject

@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) Device *device;

@end
