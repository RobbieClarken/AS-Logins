//
//  EditDeviceViewController.m
//  AS Logins
//
//  Created by Robbie Clarken on 17/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "EditDeviceViewController.h"
#import "Login+Create.h"
#import "DeviceFieldCell.h"
#import "EditLoginCell.h"

static NSString *LoginsKey = @"logins";

@interface EditDeviceViewController () <UITextFieldDelegate>

@property (strong, nonatomic) NSIndexPath *nextEditCellIndexPath;

@end

@implementation EditDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.nextEditCellIndexPath = nil;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    // Resign first responder
    [self.view endEditing:YES];
    BOOL save = !editing && self.editing;
    if (save) {
        NSMutableOrderedSet *logins = [self.device mutableOrderedSetValueForKey:LoginsKey];
        Login *lastLogin = [logins lastObject];
        if (lastLogin.username.length == 0 && lastLogin.password.length == 0) {
            [logins removeObject:lastLogin];
        }
    }
    if (editing) {
        Login *login = [Login loginInContext:self.device.managedObjectContext];
        [[self.device mutableOrderedSetValueForKey:LoginsKey] addObject:login];
    }
    if (save && self.presentingViewController) {
        return [self.delegate editDeviceTableViewController:self didFinishWithSave:YES];
    } else {
        [self.navigationItem setHidesBackButton:editing animated:animated];
        self.navigationItem.hidesBackButton = editing;
        UIBarButtonItem *leftBarButtonItem;
        if (editing) {
            leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
        }
        [self.navigationItem setLeftBarButtonItem:leftBarButtonItem animated:animated];
    }
    [super setEditing:editing animated:animated];
    [self.tableView reloadData];
}

- (void)cancelButtonPressed:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    if (self.presentingViewController) {
        [self.delegate editDeviceTableViewController:self didFinishWithSave:NO];
    } else {
        [self.managedObjectContext rollback];
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
    NSMutableOrderedSet *logins = [self.device mutableOrderedSetValueForKey:LoginsKey];
    [logins addObject:[Login loginInContext:self.device.managedObjectContext]];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
    [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self updateEditingStyleIndicators];
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
    [logins removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    if ([logins count] == 1) {
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
    if (section == 0) {
        if (self.editing) {
            return 4;
        } else {
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
        }
    } else {
        return [self.device.logins count];
    }
}

- (Login *)loginForIndexPath:(NSIndexPath *)indexPath {
    NSUInteger loginNumber = indexPath.row;
    NSOrderedSet *logins = self.device.logins;
    if (loginNumber < [logins count]) {
        return [logins objectAtIndex:loginNumber];
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
        
        textField.enabled = self.editing;
        return cell;
    } else {
        static NSString *LoginCellIdentifier = @"EditableLoginFieldCell";
        EditLoginCell *cell = [tableView dequeueReusableCellWithIdentifier:LoginCellIdentifier forIndexPath:indexPath];        
        Login *login = [self loginForIndexPath:indexPath];
        cell.usernameTextField.text = login.username;
        cell.passwordTextField.text = login.password;
        cell.usernameTextField.enabled = self.editing;
        cell.passwordTextField.enabled = self.editing;
        
        if (self.editing && [self indexPathIsLastInSection:indexPath]) {
            [cell.usernameTextField addTarget:self action:@selector(editedLastLogin:) forControlEvents:UIControlEventEditingChanged];
            [cell.passwordTextField addTarget:self action:@selector(editedLastLogin:) forControlEvents:UIControlEventEditingChanged];
        }        
        cell.usernameTextField.delegate = self;
        cell.passwordTextField.delegate = self;
        
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 1 && [self.device.logins count] > 1;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteLoginAtIndexPath:indexPath];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self indexPathIsLastInSection:indexPath]) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

#pragma mark - Text field delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSIndexPath *indexPath = [self indexPathWithView:textField];
    switch (indexPath.section) {
        case 0: {
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
            break;
        }
        case 1: {
            Login *login = self.device.logins[indexPath.row];
            switch (textField.tag) {
                case ASLLoginTextFieldUsername:
                    login.username = textField.text;
                    break;
                case ASLLoginTextFieldPassword:
                    login.password = textField.text;
                    break;
            }
            break;
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
