//
//  EditDeviceViewController.h
//  AS Logins
//
//  Created by Robbie Clarken on 17/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Device.h"

@class EditDeviceViewController;

@protocol EditLoginViewControllerDelegate <NSObject>

- (void)editDeviceTableViewControllerDidCancel:(EditDeviceViewController *)editDeviceViewController;
- (void)editDeviceTableViewControllerDidSave:(EditDeviceViewController *)editDeviceViewController;

@end

@interface EditDeviceViewController : UITableViewController

@property (weak, nonatomic) Device *device;
@property (weak, nonatomic) id <EditLoginViewControllerDelegate> delegate;

@end
