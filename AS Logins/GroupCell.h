//
//  GroupCell.h
//  AS Logins
//
//  Created by Robbie Clarken on 30/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic) BOOL stayEditable;

@end
