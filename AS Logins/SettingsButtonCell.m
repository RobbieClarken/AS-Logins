//
//  SettingsButtonCell.m
//  AS Logins
//
//  Created by Robbie Clarken on 31/05/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "SettingsButtonCell.h"

@interface SettingsButtonCell()

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation SettingsButtonCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UILabel *titleLabel = [[UILabel alloc] init];
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:titleLabel];
        [self.contentView addSubview:activityIndicatorView];
        
        NSDictionary *views = NSDictionaryOfVariableBindings(titleLabel,activityIndicatorView);
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[titleLabel]-|" options:kNilOptions metrics:nil views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleLabel]|" options:kNilOptions metrics:nil views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[activityIndicatorView]-|" options:kNilOptions metrics:nil views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[activityIndicatorView]-|" options:kNilOptions metrics:nil views:views]];
        
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        
        activityIndicatorView.hidden = YES;
    
        self.titleLabel = titleLabel;
        self.activityIndicatorView = activityIndicatorView;
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if(highlighted) {
        self.titleLabel.textColor = [UIColor whiteColor];
    } else {
        self.titleLabel.textColor = [UIColor blackColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    // Disable selection
}

- (void)startActivity {
    [self.activityIndicatorView startAnimating];
    self.titleLabel.hidden = YES;
    self.activityIndicatorView.hidden = NO;
}

- (void)stopActivity {
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden = YES;
    self.titleLabel.hidden = NO;
}

@end
