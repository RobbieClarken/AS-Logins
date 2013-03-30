//
//  EditDeviceViewController.h
//  AS Logins
//
//  Created by Robbie Clarken on 17/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"

@class DeviceViewController;

@protocol DeviceViewControllerDelegate <NSObject>

- (void)deviceViewController:(DeviceViewController *)editDeviceViewController didFinishWithSave:(BOOL)save;

@end

@interface DeviceViewController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Device *device;
@property (weak, nonatomic) id <DeviceViewControllerDelegate> delegate;

@end
