//
//  EditDeviceViewController.m
//  AS Logins
//
//  Created by Robbie Clarken on 17/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "EditDeviceViewController.h"
#import "Login.h"
#import "DeviceFieldCell.h"
#import "EditLoginCell.h"

@interface EditDeviceViewController () <UITextFieldDelegate>

@property (weak, nonatomic) NSIndexPath *nextEditCellIndexPath;

@end

@implementation EditDeviceViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.device.logins count] == 0) {
        // TODO: Add empty login
        //Login *login = [[Login alloc] initWithEntity:<#(NSEntityDescription *)#> insertIntoManagedObjectContext:<#(NSManagedObjectContext *)#>];
    }
    
    self.nextEditCellIndexPath = nil;
    [self.tableView setEditing:YES animated:NO];
}

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
    [self.delegate editLoginTableViewControllerDidCancel:self];
}


- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender {
    [self.delegate editLoginTableViewControllerDidCancel:self];
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
    // TODO: Insert empty login
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
            // TODO: Delete login
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
        switch (indexPath.row) {
            case 0:
                textField.placeholder = @"Name";
                textField.keyboardType = UIKeyboardTypeDefault;
                textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                break;
            case 1:
                textField.placeholder = @"Hostname";
                textField.keyboardType = UIKeyboardTypeDefault;
                textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
                break;
            case 2:
                textField.placeholder = @"IP";
                textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                break;
            case 3:
                textField.placeholder = @"URL";
                textField.keyboardType = UIKeyboardTypeURL;
                textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
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
    return indexPath.section == 1;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.device.logins count]) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Text field delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSIndexPath *indexPath = [self indexPathWithView:textField];
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
