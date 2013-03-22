//
//  EditLoginCell.h
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

@interface EditLoginCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end
