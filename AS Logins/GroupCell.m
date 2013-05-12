//
//  GroupCell.m
//  AS Logins
//
//  Created by Robbie Clarken on 30/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "GroupCell.h"

@interface GroupCell()

@end

@implementation GroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UITextField *textField = [[UITextField alloc] init];
        textField.font = [UIFont boldSystemFontOfSize:17.0f];
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:textField];
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(textField);
        NSDictionary *metrics = @{@"spacing": @8.0f};
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-spacing-[textField]-spacing-|" options:NSLayoutFormatAlignAllTop metrics:metrics views:viewsDictionary];
        [self.contentView addConstraints:constraints];
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textField]|" options:NSLayoutFormatAlignAllTop metrics:nil views:viewsDictionary];
        [self.contentView addConstraints:constraints];
        self.textField = textField;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    if (!self.stayEditable) {
        self.textField.enabled = editing;
        if (editing) {
            self.textField.placeholder = @"Group Name";
        } else {
            self.textField.placeholder = @"";
        }
    }
    [super setEditing:editing animated:animated];
}

@end
