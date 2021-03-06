//
//  LockViewController.m
//  AS Logins
//
//  Created by Robbie Clarken on 13/05/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "LockViewController.h"
#import "LockView.h"

static NSString *FailedAttemptsKey = @"failedAttempts";

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

- (NSUInteger)failedAttempts {
    return [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:FailedAttemptsKey] unsignedIntegerValue];
}

- (void)setFailedAttempts:(NSUInteger)failedAttempts {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInteger:failedAttempts] forKey:FailedAttemptsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self observeKeyboard];
    [self.lockView.codeTextField addTarget:self action:@selector(codeTextFieldChanged) forControlEvents:UIControlEventEditingChanged];
    
    if (self.settingCode) {
        self.lockView.messageLabel.text = @"Enter a passcode";
    } else {
        [self updateUnlockingView];
    }
    
    [self.lockView.codeTextField becomeFirstResponder];
}

- (void)observeKeyboard {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UIDeviceOrientationIsLandscape(orientation)) {
        self.lockView.keyboardHeight = keyboardFrame.size.width;
    } else {
        self.lockView.keyboardHeight = keyboardFrame.size.height;
    }
    // HACK: We use setNeedsUpdateConstraints instead of
    // layoutIfNeeded in an animation to avoid glitch where
    // subviews will animate in from the top left corner when
    // the view is loaded modally.
    [self.lockView setNeedsUpdateConstraints];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval animationDuraction = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    self.lockView.keyboardHeight = 0.0f;
    [UIView animateWithDuration:animationDuraction animations:^{
        [self.lockView layoutIfNeeded];
    }];
}

- (void)updateUnlockingView {
    if (self.allowedAttempts > 0 && self.failedAttempts >= self.allowedAttempts) {
        self.lockView.messageLabel.text = [NSString stringWithFormat:@"Access denied"];
        self.lockView.codeTextField.text = @"";
        self.lockView.codeTextField.enabled = NO;
        self.lockView.warningLabel.text = [NSString stringWithFormat:@"%i of %i incorrect attempts", self.failedAttempts, self.allowedAttempts];
    } else {
        self.lockView.messageLabel.text = @"Enter your passcode";
        self.lockView.codeTextField.text = @"";
        if (self.failedAttempts > 0) {
            self.lockView.warningLabel.text = [NSString stringWithFormat:@"%i of %i incorrect attempts", self.failedAttempts, self.allowedAttempts];
        } else {
            self.lockView.warningLabel.text = @"";
        }
    }
}

- (void)codeTextFieldChanged {    
    if ([self.lockView.codeTextField.text length] == 4) {
        NSUInteger codeHash = [self.lockView.codeTextField.text hash];
        if (self.settingCode) {
            if (self.firstEnteredCodeHash) {
                if (codeHash == self.firstEnteredCodeHash) {
                    [self.delegate lockView:self finishedSettingCodeWithCodeHash:codeHash];
                } else {
                    self.firstEnteredCodeHash = 0;
                    self.lockView.messageLabel.text = @"Enter a passcode";
                    self.lockView.warningLabel.text = @"Passcodes did not match";
                    self.lockView.codeTextField.text = @"";
                }
            } else {
                // Record code and get user to re-enter code
                self.firstEnteredCodeHash = codeHash;
                self.lockView.messageLabel.text = @"Re-enter your passcode";
                self.lockView.warningLabel.text = @"";
                self.lockView.codeTextField.text = @"";
            }
        } else {
            if ([self.delegate checkCodeHash:codeHash]) {
                self.failedAttempts = 0;
                [self.delegate lockView:self finishedUnlocking:YES];
            } else {
                self.failedAttempts += 1;
                [self updateUnlockingView];
                if (self.allowedAttempts > 0 && self.failedAttempts >= self.allowedAttempts) {
                    [self.delegate lockView:self finishedUnlocking:NO];
                }
            }
        }
    }
}

@end
