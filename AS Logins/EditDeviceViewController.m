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

@interface EditDeviceViewController ()

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
    [self.tableView setEditing:YES animated:NO];
}

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
    [self.delegate editLoginTableViewControllerDidCancel:self];
}


- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender {
    [self.delegate editLoginTableViewControllerDidCancel:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1 + [self.device.logins count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 4;
    } else {
        return 2;
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
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.detailTextLabel.text = @"";
        Login *login = [self loginForIndexPath:indexPath];
        CGRect textFrame = cell.detailTextLabel.frame;
        UITextField *textField = [[UITextField alloc] initWithFrame:textFrame];
        textField.font = cell.detailTextLabel.font;
        if (indexPath.row == 0) {
            cell.textLabel.text = @"username";
            textField.text = login.username;
            textField.placeholder = @"Username";
        } else {
            cell.textLabel.text = @"password";
            textField.text = login.password;
            textField.placeholder = @"Password";
        }
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [cell.contentView addSubview:textField];
        CGFloat linePosition = floorf((cell.textLabel.frame.origin.x + cell.textLabel.frame.size.width + cell.detailTextLabel.frame.origin.x)/2.0f);
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(linePosition, 0, 1, cell.contentView.bounds.size.height)];
        lineView.backgroundColor = self.tableView.separatorColor;
        [cell.contentView addSubview:lineView];
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeft multiplier:1.0f constant:cell.detailTextLabel.frame.origin.x];
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.0f];
        [cell.contentView addConstraints:@[leftConstraint, rightConstraint]];
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {  
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
    NSLog(@"this works");
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
