//
//  SettingsViewController.h
//  AS Logins
//
//  Created by Robbie Clarken on 31/05/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingsViewController;

@protocol SettingsViewControllerDelegate <NSObject>

- (void)dismissSettingsViewController:(SettingsViewController *)settingsViewController;

@end

@interface SettingsViewController : UITableViewController

@property (weak, nonatomic) id delegate;

@end
