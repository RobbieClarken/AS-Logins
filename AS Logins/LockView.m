//
//  LockView.m
//  AS Logins
//
//  Created by Robbie Clarken on 13/05/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "LockView.h"

@interface LockView()

@property (strong, nonatomic) NSLayoutConstraint *codeTextFieldVerticalConstraint;

@end

@implementation LockView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UITextField *codeTextField = [[UITextField alloc] init];
        
        // Alignment
        NSDictionary *views = NSDictionaryOfVariableBindings(codeTextField);
        NSDictionary *metrics = @{ @"codeTextFieldWidth": @160.0f, @"codeTextFieldHeight": @50.0f};
        codeTextField.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:codeTextField];
        NSLayoutConstraint *horizontalCenterConstraint = [NSLayoutConstraint constraintWithItem:codeTextField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
        _codeTextFieldVerticalConstraint = [NSLayoutConstraint constraintWithItem:codeTextField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[codeTextField(codeTextFieldWidth)]" options:kNilOptions metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[codeTextField(codeTextFieldHeight)]" options:kNilOptions metrics:metrics views:views]];
        [self addConstraints:@[horizontalCenterConstraint, _codeTextFieldVerticalConstraint]];
        
        // Styling
        self.backgroundColor = [UIColor whiteColor];
        codeTextField.borderStyle = UITextBorderStyleRoundedRect;
        codeTextField.secureTextEntry = YES;
        codeTextField.textAlignment = NSTextAlignmentCenter;
        codeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        codeTextField.keyboardType = UIKeyboardTypeNumberPad;
        codeTextField.font = [UIFont boldSystemFontOfSize:32.0f];
        
        self.codeTextField = codeTextField;
    }
    return self;
}

- (void)setKeyboardHeight:(CGFloat)keyboardHeight {
    if (_keyboardHeight != keyboardHeight) {
        _keyboardHeight = keyboardHeight;
        self.codeTextFieldVerticalConstraint.constant = -keyboardHeight/2.0f;
    }
}

@end
