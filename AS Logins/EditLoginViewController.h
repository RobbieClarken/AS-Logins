//
//  EditLoginViewController.h
//  AS Logins
//
//  Created by Robbie Clarken on 17/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditLoginViewController;

@protocol EditLoginViewControllerDelegate <NSObject>

- (void)editLoginTableViewControllerDidCancel:(EditLoginViewController *)editLoginViewController;
- (void)editLoginTableViewControllerDidSave:(EditLoginViewController *)editLoginViewController;

@end

@interface EditLoginViewController : UITableViewController

@property (nonatomic, weak) id <EditLoginViewControllerDelegate> delegate;

@end
