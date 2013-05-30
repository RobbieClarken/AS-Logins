//
//  LockViewController.h
//  AS Logins
//
//  Created by Robbie Clarken on 13/05/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LockViewController;

@protocol LockViewControllerDelegate <NSObject>

- (BOOL)checkCodeHash:(NSUInteger)codeHash;
- (void)lockView:(LockViewController *)lockView finishedSettingCodeWithCodeHash:(NSUInteger)codeHash;
- (void)lockView:(LockViewController *)lockView finishedUnlocking:(BOOL)success;

@end

@interface LockViewController : UIViewController

@property (nonatomic) BOOL settingCode;
@property (nonatomic) NSUInteger allowedAttempts;
@property (weak, nonatomic) id <LockViewControllerDelegate> delegate;

@end
