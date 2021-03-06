//
//  LockView.h
//  AS Logins
//
//  Created by Robbie Clarken on 13/05/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LockView : UIView

@property (strong, nonatomic) UITextField *codeTextField;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UILabel *warningLabel;
@property (nonatomic) CGFloat keyboardHeight;

@end
