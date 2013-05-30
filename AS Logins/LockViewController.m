//
//  LockViewController.m
//  AS Logins
//
//  Created by Robbie Clarken on 13/05/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "LockViewController.h"
#import "LockView.h"

@interface LockViewController ()

@property (strong, nonatomic) LockView *lockView;
@property (nonatomic) NSUInteger firstEnteredCodeHash;
@property (nonatomic) NSUInteger failedAttempts;

@end

@implementation LockViewController

- (void)loadView {
    self.lockView = [[LockView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view = self.lockView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.lockView.codeTextField becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self observeKeyboard];
    [self.lockView.codeTextField addTarget:self action:@selector(codeTextFieldChanged) forControlEvents:UIControlEventEditingChanged];
    
    if (self.settingCode) {
        self.lockView.messageLabel.text = @"Enter a passcode";
    } else {
        self.lockView.messageLabel.text = @"Enter your passcode";
    }
    
    self.firstEnteredCodeHash = 0;
    self.failedAttempts = 0;
}

- (void)observeKeyboard {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        self.lockView.keyboardHeight = keyboardFrame.size.width;
    } else {
        self.lockView.keyboardHeight = keyboardFrame.size.height;
    }
    [UIView animateWithDuration:animationDuration animations:^{
        [self.lockView layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    self.lockView.keyboardHeight = 0.0f;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.lockView layoutIfNeeded];
    }];
}

- (void)codeTextFieldChanged {
    if ([self.lockView.codeTextField.text length] == 4) {
        NSUInteger codeHash = [self.lockView.codeTextField.text hash];
        if (self.settingCode) {
            if (self.firstEnteredCodeHash) {
                if (codeHash == self.firstEnteredCodeHash) {
                    [self.delegate lockView:self finishedSettingCodeWithCodeHash:codeHash];
                } else {
                    // TODO: Handle mismatched codes
                }
            } else {
                // Record code and get user to re-enter code
                self.firstEnteredCodeHash = codeHash;
                self.lockView.messageLabel.text = @"Re-enter your passcode";
                self.lockView.codeTextField.text = @"";
            }
        } else {
            if ([self.delegate checkCodeHash:codeHash]) {
                [self.delegate lockView:self finishedUnlocking:YES];
            } else {
                self.failedAttempts += 1;
                if (self.allowedAttempts > 0 && self.failedAttempts >= self.allowedAttempts) {
                    [self.delegate lockView:self finishedUnlocking:NO];
                } else {
                    self.lockView.messageLabel.text = @"Please try again";
                    self.lockView.codeTextField.text = @"";
                }
            }
        }
    }
}

@end
