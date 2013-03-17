//
//  EditLoginTableViewController.h
//  AS Logins
//
//  Created by Robbie Clarken on 17/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditLoginTableViewControllerDelegate <NSObject>

- (void)cancelEditLogin;

@end

@interface EditLoginTableViewController : UITableViewController

@property (nonatomic, weak) id <EditLoginTableViewControllerDelegate> delegate;

@end
