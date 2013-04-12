//
//  LoginCell.h
//  AS Logins
//
//  Created by Robbie Clarken on 21/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "LoginCell.h"

@interface LoginCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usernameLeftHConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordRightHConstraint;

@end

@implementation LoginCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UITextField *usernameTextField = [self loginTextFieldWithTag:ASLLoginTextFieldUsername];
        UITextField *passwordTextField = [self loginTextFieldWithTag:ASLLoginTextFieldPassword];
        
        UIView *separatorView = [[UIView alloc] init];
        separatorView.backgroundColor = [UIColor lightGrayColor];
        separatorView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:usernameTextField];
        [self.contentView addSubview:passwordTextField];
        [self.contentView addSubview:separatorView];
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(usernameTextField,passwordTextField,separatorView);
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-[usernameTextField(==passwordTextField)]-[separatorView(1)]-[passwordTextField]-|"
                                                                                 options:NSLayoutFormatAlignAllTop
                                                                                 metrics:nil
                                                                                   views:viewsDictionary];
        [self.contentView addConstraints:constraints];
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[usernameTextField]|"
                                                              options:0
                                                              metrics:nil
                                                                views:viewsDictionary];
        [self.contentView addConstraints:constraints];
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[separatorView]|"
                                                              options:0
                                                              metrics:nil
                                                                views:viewsDictionary];
        [self.contentView addConstraints:constraints];
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[passwordTextField]|"
                                                              options:0
                                                              metrics:nil
                                                                views:viewsDictionary];
        [self.contentView addConstraints:constraints];        
        
        self.usernameTextField = usernameTextField;
        self.passwordTextField = passwordTextField;
    }
    return self;
}

- (UITextField *)loginTextFieldWithTag:(ASLLoginTextField)tag {
    UITextField *textField = [[UITextField alloc] init];
    textField.font = [UIFont boldSystemFontOfSize:17.0f];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.tag = tag;
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    return textField;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    if (!self.stayEditable) {
        self.usernameTextField.enabled = editing;
        self.passwordTextField.enabled = editing;
        if (editing) {
            self.usernameTextField.placeholder = @"Username";
            self.passwordTextField.placeholder = @"Password";
        } else {
            self.usernameTextField.placeholder = @"";
            self.passwordTextField.placeholder = @"";
        }
        
    }
    [super setEditing:editing animated:animated];
}

@end
