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
}

- (void)observeKeyboard {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGFloat animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
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
    CGFloat animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    self.lockView.keyboardHeight = 0.0f;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.lockView layoutIfNeeded];
    }];
}

- (void)codeTextFieldChanged {
    if ([self.lockView.codeTextField.text length] == 4) {
        [self.lockView.codeTextField resignFirstResponder];
    }
}

@end
