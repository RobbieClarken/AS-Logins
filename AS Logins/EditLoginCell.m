//
//  EditLoginCell.m
//  AS Logins
//
//  Created by Robbie Clarken on 21/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "EditLoginCell.h"

@interface EditLoginCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usernameLeftHConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordRightHConstraint;

@end

@implementation EditLoginCell

- (void)awakeFromNib {
    
    self.usernameTextField.tag = ASLLoginTextFieldUsername;
    self.passwordTextField.tag = ASLLoginTextFieldPassword;
    
    [self removeConstraint:self.usernameLeftHConstraint];
    [self removeConstraint:self.passwordRightHConstraint];
    
    // TODO: Get the standard spacing from somewhere smart or use visual format
    static CGFloat StandardSpacing = 8.0f;
    NSLayoutConstraint *newUsernameLeftHConstraint = [NSLayoutConstraint constraintWithItem:self.usernameTextField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0f constant:StandardSpacing];
    NSLayoutConstraint *newPasswordRightHConstraint = [NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0f constant:-StandardSpacing];
    [self addConstraints:@[newUsernameLeftHConstraint, newPasswordRightHConstraint]];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    if (!self.stayEditable) {
        self.usernameTextField.enabled = editing;
        self.passwordTextField.enabled = editing;
    }
    [super setEditing:editing animated:animated];
}

@end
