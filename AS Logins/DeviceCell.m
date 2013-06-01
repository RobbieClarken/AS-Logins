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
        
        UIView *leftView = [[UIView alloc] init];
        leftView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:leftView];
        
        UIView *rightView = [[UIView alloc] init];
        rightView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:rightView];
        
        UILabel *nameLabel = [self labelInView:leftView];
        UILabel *hostnameLabel = [self labelInView:leftView];
        UILabel *usernameLabel = [self labelInView:leftView];
        UILabel *passwordLabel = [self labelInView:leftView];
        
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(leftView,
                                                                       rightView,
                                                                       nameLabel,
                                                                       hostnameLabel,
                                                                       usernameLabel,
                                                                       passwordLabel);
        NSDictionary *metrics = @{@"sideSpacing": @8.0f};
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-sideSpacing-[nameLabel(==usernameLabel)][usernameLabel]|" options:kNilOptions metrics:metrics views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-sideSpacing-[hostnameLabel(==passwordLabel)][passwordLabel]|" options:kNilOptions metrics:metrics views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[nameLabel(==hostnameLabel)][hostnameLabel]|" options:kNilOptions metrics:metrics views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[usernameLabel(==passwordLabel)][passwordLabel]|" options:kNilOptions metrics:metrics views:viewsDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[leftView][rightView(50)]|" options:kNilOptions metrics:metrics views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[leftView]|" options:kNilOptions metrics:metrics views:viewsDictionary]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[rightView]|" options:kNilOptions metrics:metrics views:viewsDictionary]];
        
        //[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[loginCountLabel]|" options:kNilOptions metrics:metrics views:viewsDictionary]];
        //[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[loginCountLabel]|" options:kNilOptions metrics:metrics views:viewsDictionary]];
        

        //loginCountLabel.backgroundColor = [UIColor blueColor];
        
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
        
        self.badge.fontSize = 14.0f;
        self.badge.radius = 10;
        
        
        self.accessoryType =UITableViewCellAccessoryDisclosureIndicator;
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

- (void)setLoginCount:(NSUInteger)loginCount {
    if (_loginCount != loginCount) {
        _loginCount = loginCount;
        self.badgeString = [NSString stringWithFormat:@"%i", loginCount];
    }
}

- (UILabel *)labelInView:(UIView *)view {
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:label];
    return label;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if(highlighted) {
        UIColor *textColor = [UIColor whiteColor];
        self.nameLabel.textColor = textColor;
        self.hostnameLabel.textColor = textColor;
        self.usernameLabel.textColor = textColor;
        self.passwordLabel.textColor = textColor;
    } else {
        UIColor *textColor = [UIColor blackColor];
        self.nameLabel.textColor = textColor;
        self.hostnameLabel.textColor = textColor;
        self.usernameLabel.textColor = textColor;
        self.passwordLabel.textColor = textColor;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if(selected) {
        UIColor *textColor = [UIColor whiteColor];
        self.nameLabel.textColor = textColor;
        self.hostnameLabel.textColor = textColor;
        self.usernameLabel.textColor = textColor;
        self.passwordLabel.textColor = textColor;
    } else {
        UIColor *textColor = [UIColor blackColor];
        self.nameLabel.textColor = textColor;
        self.hostnameLabel.textColor = textColor;
        self.usernameLabel.textColor = textColor;
        self.passwordLabel.textColor = textColor;
    }
}

@end
