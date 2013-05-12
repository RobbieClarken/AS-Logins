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
@property (strong, nonatomic) UILabel *loginLabel;
@property (strong, nonatomic) UILabel *additionalLoginsLabel;

@end

@implementation DeviceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UILabel *nameLabel = [self labelInContentView];
        UILabel *hostnameLabel = [self labelInContentView];
        UILabel *loginLabel = [self labelInContentView];
        UILabel *additionalLoginsLabel = [self labelInContentView];
        
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(nameLabel, hostnameLabel, loginLabel,additionalLoginsLabel);
        NSDictionary *metrics = @{@"sideSpacing": @8.0f};
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-sideSpacing-[nameLabel(==loginLabel)][loginLabel]-sideSpacing-|" options:kNilOptions metrics:metrics views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-sideSpacing-[hostnameLabel(==additionalLoginsLabel)][additionalLoginsLabel]-sideSpacing-|" options:kNilOptions metrics:metrics views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[nameLabel(==hostnameLabel)][hostnameLabel]|" options:kNilOptions metrics:metrics views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[loginLabel(==additionalLoginsLabel)][additionalLoginsLabel]|" options:kNilOptions metrics:metrics views:viewsDictionary]];
        
        nameLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        hostnameLabel.font = [UIFont systemFontOfSize:14.0f];
        
        nameLabel.textAlignment = NSTextAlignmentLeft;
        hostnameLabel.textAlignment = NSTextAlignmentLeft;
        loginLabel.textAlignment = NSTextAlignmentRight;
        additionalLoginsLabel.textAlignment = NSTextAlignmentRight;
    
        loginLabel.adjustsFontSizeToFitWidth = YES;
        
        self.nameLabel = nameLabel;
        self.hostnameLabel = hostnameLabel;
        self.loginLabel = loginLabel;
        self.additionalLoginsLabel = additionalLoginsLabel;
    }
    
    return self;
}

- (void)updateLoginLabel {
    self.loginLabel.text = [NSString stringWithFormat:@"%@:%@", self.username, self.password];
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
        [self updateLoginLabel];
    }
}

- (void)setPassword:(NSString *)password {
    if (![_password isEqualToString:password]) {
        _password = password;
        [self updateLoginLabel];
    }
}

- (void)setAdditionalLogins:(NSUInteger)additionalLogins {
    if (_additionalLogins != additionalLogins) {
        _additionalLogins = additionalLogins;
        if (additionalLogins > 0) {
            self.additionalLoginsLabel.text = [NSString stringWithFormat:@"(+%i)", additionalLogins];
            self.additionalLoginsLabel.hidden = NO;
        } else {
            self.additionalLoginsLabel.hidden = YES;
        }
    }
}

- (UILabel *)labelInContentView {
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:label];
    return label;
}

@end
