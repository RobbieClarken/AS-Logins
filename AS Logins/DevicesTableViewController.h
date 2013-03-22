//
//  DevicesTableViewController.h
//  AS Logins
//
//  Created by Robbie Clarken on 17/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"

@interface DevicesTableViewController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Group *group;

@end
