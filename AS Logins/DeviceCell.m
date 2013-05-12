//
//  DeviceCell.m
//  AS Logins
//
//  Created by Robbie Clarken on 12/04/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "DeviceCell.h"

@interface DeviceCell()

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *hostnameLabel;
@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) UILabel *passwordLabel;

@end

@implementation DeviceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UILabel *nameLabel = [self labelInContentView];
        UILabel *hostnameLabel = [self labelInContentView];
        UILabel *usernameLabel = [self labelInContentView];
        UILabel *passwordLabel = [self labelInContentView];
        
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(nameLabel, hostnameLabel, usernameLabel,passwordLabel);
        NSDictionary *metrics = @{@"sideSpacing": @8.0f};
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-sideSpacing-[nameLabel(==usernameLabel)][usernameLabel]-sideSpacing-|" options:kNilOptions metrics:metrics views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-sideSpacing-[hostnameLabel(==passwordLabel)][passwordLabel]-sideSpacing-|" options:kNilOptions metrics:metrics views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[nameLabel(==hostnameLabel)][hostnameLabel]|" options:kNilOptions metrics:metrics views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[usernameLabel(==passwordLabel)][passwordLabel]|" options:kNilOptions metrics:metrics views:viewsDictionary]];
        
        nameLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        hostnameLabel.font = [UIFont systemFontOfSize:14.0f];
        
        usernameLabel.font = [UIFont fontWithName:@"Courier" size:16.0f];
        passwordLabel.font = [UIFont fontWithName:@"Courier" size:16.0f];
        
        nameLabel.textAlignment = NSTextAlignmentLeft;
        hostnameLabel.textAlignment = NSTextAlignmentLeft;
        usernameLabel.textAlignment = NSTextAlignmentRight;
        passwordLabel.textAlignment = NSTextAlignmentRight;
    
        usernameLabel.adjustsFontSizeToFitWidth = YES;
        passwordLabel.adjustsFontSizeToFitWidth = YES;
        
        self.nameLabel = nameLabel;
        self.hostnameLabel = hostnameLabel;
        self.usernameLabel = usernameLabel;
        self.passwordLabel = passwordLabel;
    }
    
    return self;
}

- (void)setName:(NSString *)name {
    if (![_name isEqualToString:name]) {
        _name = name;
        self.nameLabel.text = name;
    }
}

- (void)setHostname:(NSString *)hostname {
    if (![_hostname isEqualToString:hostname]) {
        _hostname = hostname;
        self.hostnameLabel.text = hostname;
    }
}

- (void)setUsername:(NSString *)username {
    if (![_username isEqualToString:username]) {
        _username = username;
        self.usernameLabel.text = username;
    }
}

- (void)setPassword:(NSString *)password {
    if (![_password isEqualToString:password]) {
        _password = password;
        self.passwordLabel.text = password;
    }
}

- (UILabel *)labelInContentView {
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:label];
    return label;
}

@end
