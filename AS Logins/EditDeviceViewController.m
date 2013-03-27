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

@interface EditDeviceViewController () <UITextFieldDelegate>

@property (strong, nonatomic) NSIndexPath *nextEditCellIndexPath;

@end

@implementation EditDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", self.device.managedObjectContext);
    
    if ([self.device.logins count] == 0) {
        Login *login = [Login loginInContext:self.device.managedObjectContext];
        //self.device.logins = [NSOrderedSet orderedSetWithObject:login];
        [[self.device mutableOrderedSetValueForKey:@"logins"] addObject:login];
    }
    
    self.nextEditCellIndexPath = nil;
    [self.tableView setEditing:YES animated:NO];
}

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    [self.delegate editDeviceTableViewController:self didFinishWithSave:NO];
}

- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    [self.delegate editDeviceTableViewController:self didFinishWithSave:YES];
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
    NSMutableOrderedSet *logins = [self.device mutableOrderedSetValueForKey:@"logins"];
    [logins addObject:[Login loginInContext:self.device.managedObjectContext]];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
    [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
            NSMutableOrderedSet *logins = [self.device mutableOrderedSetValueForKey:@"logins"];
            [logins removeObjectAtIndex:indexPath.row];
            if ([logins count] == 1) {
                [self.tableView reloadData];
            } else {
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    }
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
    NSUInteger loginNumber = indexPath.section - 1;
    NSOrderedSet *logins = self.device.logins;
    if (loginNumber < [logins count]) {
        return [logins objectAtIndex:loginNumber];
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSString *cellIdentifier = @"EditableDeviceFieldCell";
        DeviceFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
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
        NSString *cellIdentifier = @"EditableLoginFieldCell";
        EditLoginCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];        
        Login *login = [self loginForIndexPath:indexPath];
        if (login) {
            cell.usernameTextField.text = login.username;
            cell.passwordTextField.text = login.password;
        } else {
            cell.usernameTextField.text = @"";
            cell.passwordTextField.text = @"";
        }
        
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
