//
//  DeviceCell.h
//  AS Logins
//
//  Created by Robbie Clarken on 12/04/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDBadgedCell.h"

@interface DeviceCell : TDBadgedCell

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *hostname;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (nonatomic) NSUInteger loginCount;

@end
