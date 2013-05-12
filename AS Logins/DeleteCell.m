//
//  DeleteCell.m
//  AS Logins
//
//  Created by Robbie Clarken on 12/05/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "DeleteCell.h"

@implementation DeleteCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Delete background
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:deleteButton];
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(deleteButton);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[deleteButton]|" options:kNilOptions metrics:0 views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[deleteButton]|" options:kNilOptions metrics:0 views:viewsDictionary]];
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"red_button.png"] forState:UIControlStateNormal];
        [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
        deleteButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont buttonFontSize]];
        self.deleteButton = deleteButton;
    }
    return self;
}

@end
