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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [self removeConstraint:self.usernameLeftHConstraint];
    [self removeConstraint:self.passwordRightHConstraint];
    
    // TODO: Get the standard spacing from somewhere smart or use visual format
    CGFloat standardSpacing = 8.0f;
    NSLayoutConstraint *newUsernameLeftHConstraint = [NSLayoutConstraint constraintWithItem:self.usernameTextField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0f constant:standardSpacing];
    NSLayoutConstraint *newPasswordRightHConstraint = [NSLayoutConstraint constraintWithItem:self.passwordTextField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0f constant:-standardSpacing];
    [self addConstraints:@[newUsernameLeftHConstraint, newPasswordRightHConstraint]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
