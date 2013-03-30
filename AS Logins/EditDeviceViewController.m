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
    if ([self.device.logins count] == 0) {
        Login *login = [Login loginInContext:self.device.managedObjectContext];
        [[self.device mutableOrderedSetValueForKey:LoginsKey] addObject:login];
    }
    self.tableView.editing = YES;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.nextEditCellIndexPath = nil;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (!editing && self.presentingViewController) {
        [self.view endEditing:YES];
        [self.delegate editDeviceTableViewController:self didFinishWithSave:YES];
    } else {
        [self.navigationItem setHidesBackButton:editing animated:animated];
        self.navigationItem.hidesBackButton = editing;
        UIBarButtonItem *leftBarButtonItem;
        if (editing) {
            leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
        }
        [self.navigationItem setLeftBarButtonItem:leftBarButtonItem animated:animated];
        [self.tableView setEditing:editing animated:animated];
        [self.tableView reloadData];
    }
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
        NSString *trimmedUsername = [editLoginCell.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *trimmedPassword = [editLoginCell.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([trimmedUsername length] == 0 && [trimmedPassword length] == 0) {
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
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
        return cell;
    } else {
        static NSString *LoginCellIdentifier = @"EditableLoginFieldCell";
        EditLoginCell *cell = [tableView dequeueReusableCellWithIdentifier:LoginCellIdentifier forIndexPath:indexPath];        
        Login *login = [self loginForIndexPath:indexPath];
        cell.usernameTextField.text = login.username;
        cell.passwordTextField.text = login.password;
        if ([self indexPathIsLastInSection:indexPath]) {
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
