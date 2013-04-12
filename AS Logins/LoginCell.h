//
//  LoginCell.h
//  AS Logins
//
//  Created by Robbie Clarken on 21/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ASLLoginTextField) {
    ASLLoginTextFieldUsername,
    ASLLoginTextFieldPassword
};

@interface LoginCell : UITableViewCell

@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (nonatomic) BOOL stayEditable;

@end
