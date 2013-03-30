//
//  GroupCell.m
//  AS Logins
//
//  Created by Robbie Clarken on 30/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "GroupCell.h"

@interface GroupCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftHConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightHConstraint;

@end

@implementation GroupCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.textField.placeholder = @"New Group Name";
    
    static CGFloat StandardSpacing = 8.0f;
    [self removeConstraints:@[self.leftHConstraint, self.rightHConstraint]];
    self.leftHConstraint = [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0f constant:StandardSpacing];
    self.rightHConstraint = [NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0f constant:-StandardSpacing];
    [self addConstraints:@[self.leftHConstraint, self.rightHConstraint]];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    self.textField.enabled = editing;
    [super setEditing:editing animated:animated];
}

@end
