//
//  EditDeviceViewController.m
//  AS Logins
//
//  Created by Robbie Clarken on 17/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "DeviceViewController.h"
#import "Login+Create.h"
#import "DeviceFieldCell.h"
#import "EditLoginCell.h"

static NSString *LoginsKey = @"logins";

@interface DeviceViewController () <UITextFieldDelegate>

@property (strong, nonatomic) NSIndexPath *nextEditCellIndexPath;

@end

@implementation DeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.nextEditCellIndexPath = nil;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    // Resign first responder
    [self.view endEditing:!editing];
    BOOL save = !editing && self.editing;
    if (save) {
        if (self.presentingViewController) {
            return [self.delegate deviceViewController:self didFinishWithSave:YES];
        } else {
            NSError *error;
            [self.device.managedObjectContext save:&error];
            if (error) {
                NSLog(@"Unresolved error in %s: %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
                abort();
            }
        }
    }
    [self.navigationItem setHidesBackButton:editing animated:animated];
    self.navigationItem.hidesBackButton = editing;
    UIBarButtonItem *leftBarButtonItem;
    if (editing) {
        leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    }
    [self.navigationItem setLeftBarButtonItem:leftBarButtonItem animated:animated];
    [super setEditing:editing animated:animated];
    [self.tableView reloadData];
}

- (void)cancelButtonPressed:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    if (self.presentingViewController) {
        [self.delegate deviceViewController:self didFinishWithSave:NO];
    } else {
        [self.device.managedObjectContext rollback];
        [self setEditing:NO animated:YES];
    }
}

- (NSIndexPath *)indexPathWithView:(UIView *)view {
    CGPoint textFieldLocation = [view convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:textFieldLocation];
    return indexPath;
}

- (void)editedLastLogin:(UITextField *)textField {
    NSIndexPath *indexPath = [self indexPathWithView:textField];
    EditLoginCell *loginCell = (EditLoginCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [loginCell.usernameTextField removeTarget:self action:@selector(editedEmptyLogin:) forControlEvents:UIControlEventEditingChanged];
    [loginCell.passwordTextField removeTarget:self action:@selector(editedEmptyLogin:) forControlEvents:UIControlEventEditingChanged];
    [Login loginForDevice:self.device inContext:self.device.managedObjectContext];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
    [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    // Hack to update editing style indicators without resigning first responder
    loginCell.stayEditable = YES;
    [self updateEditingStyleIndicators];
    loginCell.stayEditable = NO;
}

- (BOOL)indexPathIsLastInSection:(NSIndexPath *)indexPath {
    return indexPath.row == [self.tableView numberOfRowsInSection:indexPath.section] - 1;
}

- (void)didEndEditingCellAtIndexPath:(NSIndexPath *)indexPath {
    if ([self indexPathIsLastInSection:indexPath]) {
        return;
    }
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[EditLoginCell class]]) {
        EditLoginCell *editLoginCell = (EditLoginCell *)cell;
        if (editLoginCell.usernameTextField.text.length == 0 && editLoginCell.passwordTextField.text.length == 0) {
            [self deleteLoginAtIndexPath:indexPath];
        }
    }
}

- (void)deleteLoginAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableOrderedSet *logins = [self.device mutableOrderedSetValueForKey:LoginsKey];
    Login *login = logins[indexPath.row];
    [logins removeObject:login];
    [self.device.managedObjectContext deleteObject:login];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    if ([self.device.logins count] == 0) {
        [self updateEditingStyleIndicators];
    }
}

- (void)updateEditingStyleIndicators {
    self.tableView.editing = NO;
    self.tableView.editing = YES;
}

- (NSString *)deviceFieldValueForRow:(NSUInteger)row {
    NSArray *deviceFieldNames = @[@"name", @"hostname", @"ip", @"url"];
    NSUInteger nonEmptyFieldCount = 0;
    for (NSString *name in deviceFieldNames) {
        NSString *value = [self.device valueForKey:name];
        if (value.length > 0) {
            nonEmptyFieldCount += 1;
        }
        if (nonEmptyFieldCount > row) {
            return value;
        }
    }
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.editing) {
        if (section == 0) {
            return 4;
        } else {
            return [self.device.logins count]+1;
        }
    } else {
        if (section == 0) {
            NSUInteger numberOfRows = 0;
            if (self.device.name.length > 0) {
                numberOfRows += 1;
            }
            if (self.device.hostname.length > 0) {
                numberOfRows += 1;
            }
            if (self.device.ip.length > 0) {
                numberOfRows += 1;
            }
            if (self.device.url.length > 0) {
                numberOfRows += 1;
            }
            return numberOfRows;
        } else {
            return [self.device.logins count];
        }
    }
}

- (Login *)loginForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.device.logins count]) {
        return [self.device.logins objectAtIndex:indexPath.row];
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *DeviceFieldCellIdentifier = @"EditableDeviceFieldCell";
        DeviceFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:DeviceFieldCellIdentifier forIndexPath:indexPath];
        UITextField *textField = cell.textField;
        textField.delegate = self;
        if (self.editing) {
            switch (indexPath.row) {
                case 0:
                    textField.placeholder = @"Name";
                    textField.keyboardType = UIKeyboardTypeDefault;
                    textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                    textField.text = self.device.name;
                    break;
                case 1:
                    textField.placeholder = @"Hostname";
                    textField.keyboardType = UIKeyboardTypeDefault;
                    textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
                    textField.text = self.device.hostname;
                    break;
                case 2:
                    textField.placeholder = @"IP";
                    textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    textField.text = self.device.ip;
                    break;
                case 3:
                    textField.placeholder = @"URL";
                    textField.keyboardType = UIKeyboardTypeURL;
                    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    textField.text = self.device.url;
                    break;
            }
        } else {
            textField.text = [self deviceFieldValueForRow:indexPath.row];
        }
        return cell;
    } else {
        static NSString *LoginCellIdentifier = @"EditableLoginFieldCell";
        EditLoginCell *cell = [tableView dequeueReusableCellWithIdentifier:LoginCellIdentifier forIndexPath:indexPath];
        Login *login = [self loginForIndexPath:indexPath];
        cell.usernameTextField.text = login.username;
        cell.passwordTextField.text = login.password;
        if (self.editing && [self indexPathIsLastInSection:indexPath]) {
            [cell.usernameTextField addTarget:self action:@selector(editedLastLogin:) forControlEvents:UIControlEventEditingChanged];
            [cell.passwordTextField addTarget:self action:@selector(editedLastLogin:) forControlEvents:UIControlEventEditingChanged];
        }        
        cell.usernameTextField.delegate = self;
        cell.passwordTextField.delegate = self;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteLoginAtIndexPath:indexPath];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && ![self indexPathIsLastInSection:indexPath]) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 1 && [self.tableView numberOfRowsInSection:indexPath.section] > 1;
}

#pragma mark - Text field delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSIndexPath *indexPath = [self indexPathWithView:textField];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                self.device.name = textField.text;
                break;
            case 1:
                self.device.hostname = textField.text;
                break;
            case 2:
                self.device.ip = textField.text;
                break;
            case 3:
                self.device.url = textField.text;
                break;
        }
    } else {
        // The last row is the template and does not have a Login object (if text had been added
        // then a Login would have been created and it would no longer be the last object)
        if (![self indexPathIsLastInSection:indexPath]) {
            Login *login = self.device.logins[indexPath.row];
            switch (textField.tag) {
                case ASLLoginTextFieldUsername:
                    login.username = textField.text;
                    break;
                case ASLLoginTextFieldPassword:
                    login.password = textField.text;
                    break;
            }
        }
    }
    
    if (indexPath && ![indexPath isEqual:self.nextEditCellIndexPath]) {
        [self didEndEditingCellAtIndexPath:indexPath];
    }
    self.nextEditCellIndexPath = nil;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {    
    self.nextEditCellIndexPath = [self indexPathWithView:textField];
    return YES;
}

@end
