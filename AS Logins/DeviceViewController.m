//
//  DeviceViewController.m
//  AS Logins
//
//  Created by Robbie Clarken on 17/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "DeviceViewController.h"
#import "Login+Create.h"
#import "DeviceFieldCell.h"
#import "LoginCell.h"
#import "EncryptionTransformer.h"
#import "NSData+Base64.h"
#import "AppDelegate.h"

static NSString *DeviceFieldCellIdentifier = @"DeviceFieldCellIdentifier";
static NSString *LoginCellIdentifier = @"LoginCellIdentifier";

typedef NS_ENUM(NSUInteger, ASLTableViewSection) {
    ASLTableViewSectionDeviceInfo = 0,
    ASLTableViewSectionLogins = 1
};

@interface DeviceViewController () <UITextFieldDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSIndexPath *nextEditCellIndexPath;
@property (strong, nonatomic) NSFetchedResultsController *loginsFetchedResultsController;
@property (nonatomic) BOOL cellReloadedDueToTextFieldChange;
@property (strong, nonatomic) NSIndexPath *indexPathOfEditingCell;
@property (nonatomic) ASLLoginTextField textFieldToBecomeFirstResponder;
@property (strong, nonatomic) EncryptionTransformer *encryptionTransformer;

@property (nonatomic) BOOL changeIsUserDriven;

@end

@implementation DeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Device";
    [self.tableView registerClass:[DeviceFieldCell class] forCellReuseIdentifier:DeviceFieldCellIdentifier];
    [self.tableView registerClass:[LoginCell class] forCellReuseIdentifier:LoginCellIdentifier];

    self.loginsFetchedResultsController.delegate = self;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.cellReloadedDueToTextFieldChange = NO;
    self.nextEditCellIndexPath = nil;
    
    self.encryptionTransformer = [[EncryptionTransformer alloc] init];
}

- (NSString *)encryptString:(NSString *)string {
    return [NSData encodeBase64WithData:[self.encryptionTransformer transformedValue:string]];
}

- (NSString *)decryptString:(NSString *)string {
    return (NSString *)[self.encryptionTransformer reverseTransformedValue:[NSData decodeBase64WithString:string]];
}

- (NSFetchedResultsController *)loginsFetchedResultsController {
    if (_loginsFetchedResultsController) {
        return _loginsFetchedResultsController;
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Login"];
    request.predicate = [NSPredicate predicateWithFormat:@"device = %@ AND toDelete == NO", self.device];
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:YES] ];
    _loginsFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.device.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    [_loginsFetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"Unresolved error in %s: %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
        abort();
    }
    return _loginsFetchedResultsController;
}

- (NSUInteger)numberOfLogins {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.loginsFetchedResultsController.sections[0];
    return sectionInfo.numberOfObjects;
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
            [(AppDelegate *)[UIApplication sharedApplication].delegate initiateSync:^(BOOL success) {}];
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
    LoginCell *loginCell = (LoginCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [loginCell.usernameTextField removeTarget:self action:@selector(editedEmptyLogin:) forControlEvents:UIControlEventEditingChanged];
    [loginCell.passwordTextField removeTarget:self action:@selector(editedEmptyLogin:) forControlEvents:UIControlEventEditingChanged];
    self.cellReloadedDueToTextFieldChange = YES;
    self.textFieldToBecomeFirstResponder = textField.tag;
    [Login loginForDevice:self.device inContext:self.device.managedObjectContext];
}

- (BOOL)indexPathIsLastInSection:(NSIndexPath *)indexPath {
    return indexPath.row == [self.tableView numberOfRowsInSection:indexPath.section] - 1;
}

- (void)didEndEditingCellAtIndexPath:(NSIndexPath *)indexPath {
    // Method for deleting login cells when both the username and password are cleared
    if ([self indexPathIsLastInSection:indexPath]) {
        return;
    }
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[LoginCell class]]) {
        LoginCell *editLoginCell = (LoginCell *)cell;
        if (editLoginCell.usernameTextField.text.length == 0 && editLoginCell.passwordTextField.text.length == 0) {
            [self deleteLoginAtIndexPath:indexPath];
        }
    }
}

- (void)deleteLoginAtIndexPath:(NSIndexPath *)indexPath {
    Login *login = [self loginForIndexPath:indexPath];
    login.toDelete = @YES;
    login.lastModifiedDate = [NSDate date];
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

#pragma mark - Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
    if (self.indexPathOfEditingCell) {
        LoginCell *cell = (LoginCell *)[self.tableView cellForRowAtIndexPath:self.indexPathOfEditingCell];
        switch (self.textFieldToBecomeFirstResponder) {
            case ASLLoginTextFieldUsername:
                [cell.usernameTextField becomeFirstResponder];
                break;
            case ASLLoginTextFieldPassword:
                [cell.passwordTextField becomeFirstResponder];
                break;
        }
        self.indexPathOfEditingCell = nil;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    
    if (self.changeIsUserDriven) {
        self.changeIsUserDriven = NO;
        return;
    }
    
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:ASLTableViewSectionLogins];
    if (newIndexPath) {
        newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:ASLTableViewSectionLogins];
    }
    switch(type) {
        case NSFetchedResultsChangeInsert: {
            if (self.cellReloadedDueToTextFieldChange) {
                NSIndexPath *insertedIndexPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:newIndexPath.section] inSection:newIndexPath.section];
                [tableView insertRowsAtIndexPaths:@[insertedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [tableView reloadRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                self.indexPathOfEditingCell = newIndexPath;
            } else {
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            break;
        }
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            // HACK: If you deleted the second to last login cell, the last login cell should no longer show the
            // delete editing style indicator so we force a reload of this cell.
            if (self.editing && [self numberOfLogins] == 0) {
                [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:ASLTableViewSectionLogins]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            break;
        case NSFetchedResultsChangeUpdate:
            // If cellReloadedDueToTextFieldChange is YES then this is only
            // being called because the textField was dismissed in what was
            // the empty group cell. The update of this cell will have already
            // have been triggered by the NSFetchedResultsChangeInsert change.
            if (self.cellReloadedDueToTextFieldChange) {
                self.cellReloadedDueToTextFieldChange = NO;
            } else {
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.editing) {
        if (section == ASLTableViewSectionDeviceInfo) {
            return 4;
        } else {
            return [self numberOfLogins]+1;
        }
    } else {
        if (section == ASLTableViewSectionDeviceInfo) {
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
            return [self numberOfLogins];
        }
    }
}

- (Login *)loginForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self numberOfLogins]) {
        return [self.loginsFetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    } else {
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"Logins";
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
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
        LoginCell *cell = [tableView dequeueReusableCellWithIdentifier:LoginCellIdentifier forIndexPath:indexPath];
        Login *login = [self loginForIndexPath:indexPath];
        cell.usernameTextField.text = [self decryptString:login.username];
        cell.passwordTextField.text = [self decryptString:login.password];
        if (self.editing && [self indexPathIsLastInSection:indexPath]) {            
            [cell.usernameTextField addTarget:self action:@selector(editedLastLogin:) forControlEvents:UIControlEventEditingChanged];
            [cell.passwordTextField addTarget:self action:@selector(editedLastLogin:) forControlEvents:UIControlEventEditingChanged];
        } else {
            [cell.usernameTextField removeTarget:self action:@selector(editedLastLogin:) forControlEvents:UIControlEventEditingChanged];
            [cell.passwordTextField removeTarget:self action:@selector(editedLastLogin:) forControlEvents:UIControlEventEditingChanged];
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
    if (indexPath.section == ASLTableViewSectionLogins && ![self indexPathIsLastInSection:indexPath]) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == ASLTableViewSectionLogins && [self.tableView numberOfRowsInSection:indexPath.section] > 1;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - Text field delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSIndexPath *indexPath = [self indexPathWithView:textField];
    if (indexPath.section == ASLTableViewSectionDeviceInfo) {
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
        self.device.lastModifiedDate = [NSDate date];
    } else if (![self indexPathIsLastInSection:indexPath]) {
        // The last row is the template and does not have a Login object (if text had been added
        // then a Login would have been created and it would no longer be the last object)
        
        if ([indexPath isEqual:self.nextEditCellIndexPath]) {
            self.cellReloadedDueToTextFieldChange = YES;
        }
        
        Login *login = [self loginForIndexPath:indexPath];
        switch (textField.tag) {
            case ASLLoginTextFieldUsername:
                self.changeIsUserDriven = YES;
                login.username = [self encryptString:textField.text];
                break;
            case ASLLoginTextFieldPassword:
                self.changeIsUserDriven = YES;
                login.password = [self encryptString:textField.text];
                break;
        }
        login.lastModifiedDate = [NSDate date];
    }
    if (indexPath && ![indexPath isEqual:self.nextEditCellIndexPath]) {
        [self didEndEditingCellAtIndexPath:indexPath];
    }
    self.nextEditCellIndexPath = nil;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    // This is used to avoid calling didEndEditingCellAtIndexPath
    // when the user clicks from the username textfield to the
    // password textfield (or vice versa) within the same cell.
    self.nextEditCellIndexPath = [self indexPathWithView:textField];
    return YES;
}

@end
