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
        UILabel *messageLabel = [[UILabel alloc] init];
        UITextField *codeTextField = [[UITextField alloc] init];
        
        // Alignment
        messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        codeTextField.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(messageLabel, codeTextField);
        NSDictionary *metrics = @{ @"codeTextFieldWidth": @160.0f,
                                   @"codeTextFieldHeight": @50.0f,
                                   @"messageToCodeSeperation": @20.0f};
        
        [self addSubview:messageLabel];
        [self addSubview:codeTextField];
        
        _codeTextFieldVerticalConstraint = [NSLayoutConstraint constraintWithItem:codeTextField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
        [self addConstraints:@[
            _codeTextFieldVerticalConstraint,
            [NSLayoutConstraint constraintWithItem:messageLabel attribute:NSLayoutAttributeCenterX
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self attribute:NSLayoutAttributeCenterX
                                        multiplier:1.0f constant:0.0f],
            [NSLayoutConstraint constraintWithItem:codeTextField attribute:NSLayoutAttributeCenterX
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self attribute:NSLayoutAttributeCenterX
                                        multiplier:1.0f constant:0.0f]
         ]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[messageLabel]-|" options:kNilOptions metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[codeTextField(codeTextFieldWidth)]" options:kNilOptions metrics:metrics views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[messageLabel]-messageToCodeSeperation-[codeTextField(codeTextFieldHeight)]" options:kNilOptions metrics:metrics views:views]];
        
        // Styling
        self.backgroundColor = [UIColor whiteColor];
        
        messageLabel.font = [UIFont systemFontOfSize:24.0f];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        
        codeTextField.borderStyle = UITextBorderStyleRoundedRect;
        codeTextField.secureTextEntry = YES;
        codeTextField.keyboardType = UIKeyboardTypeNumberPad;
        codeTextField.font = [UIFont boldSystemFontOfSize:32.0f];
        codeTextField.textAlignment = NSTextAlignmentCenter;
        codeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        self.messageLabel = messageLabel;
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
