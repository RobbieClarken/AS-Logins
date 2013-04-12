//
//  DeviceFieldCell.m
//  AS Logins
//
//  Created by Robbie Clarken on 21/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "DeviceFieldCell.h"

@interface DeviceFieldCell()

@end

@implementation DeviceFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UITextField *textField = [[UITextField alloc] init];
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.font = [UIFont boldSystemFontOfSize:17.0f];
        [self.contentView addSubview:textField];
        NSDictionary *metrics = @{@"spacing": @8.0f};
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(textField);
        NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-spacing-[textField]-spacing-|"
                                                                                options:0
                                                                                metrics:metrics
                                                                                  views:viewsDictionary];
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textField]|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:viewsDictionary];
        [self.contentView addConstraints:horizontalConstraints];
        [self.contentView addConstraints:verticalConstraints];
        self.textField = textField;
    }
    return self;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    self.textField.enabled = editing;
    [super setEditing:editing animated:animated];
}

@end
