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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    self.textField.enabled = editing;
    [super setEditing:editing animated:animated];
}

@end
