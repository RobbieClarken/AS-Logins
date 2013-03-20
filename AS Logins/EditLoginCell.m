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
    // TODO: Get the standard spacing from somewhere smart or use visual format
    CGFloat standardSpacing = 8.0f;
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.usernameTextField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0f constant:standardSpacing];
    [self addConstraint:constraint];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
