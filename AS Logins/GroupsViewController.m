//
//  GroupsViewController.m
//  AS Logins
//
//  Created by Robbie Clarken on 22/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "GroupsViewController.h"
#import "Group+Create.h"
#import "DevicesTableViewController.h"
#import "GroupCell.h"

static NSUInteger GroupPositionStep = 0x10000;

@interface GroupsViewController () <UITextFieldDelegate>

@property (nonatomic, strong) NSArray *groups;

@end

@implementation GroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateGroups];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)updateGroups {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES]];
    NSError *error;
    // TODO: Handle error
    self.groups = [self.managedObjectContext executeFetchRequest:request error:&error];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self.view endEditing:!editing];
    BOOL save = !editing && self.editing;
    if (save) {
        NSError *error;
        [self.managedObjectContext save:&error];
        if (error) {
            NSLog(@"Unresolved error in %s: %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
            abort();
        }
    }
    [super setEditing:editing animated:animated];
    [self.tableView reloadData];
}

- (void)editedEmptyGroup:(UITextField *)textField {
    [textField removeTarget:self action:@selector(editedEmptyGroup:) forControlEvents:UIControlEventEditingChanged];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[self.tableView convertPoint:CGPointZero fromView:textField]];
    if (indexPath.row == [self.tableView numberOfRowsInSection:indexPath.section]-1) {
        NSUInteger positionInt;
        if (indexPath.row == 0) {
            positionInt = GroupPositionStep;
        } else {
            positionInt = [[(Group *)self.groups.lastObject position] integerValue] + GroupPositionStep;
        }
        [Group groupWithName:@"" atPosition:[NSNumber numberWithInt:positionInt] inContext:self.managedObjectContext];
        [self updateGroups];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.editing) {
        return [self.groups count] + 1;
    } else {
        return [self.groups count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GroupCell";
    GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (indexPath.row < [self.groups count]) {
        cell.textField.text = [self.groups[indexPath.row] name];
    } else {
        cell.textField.text = @"";
        [cell.textField addTarget:self action:@selector(editedEmptyGroup:) forControlEvents:UIControlEventEditingChanged];
    }
    cell.textField.delegate = self;
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    DevicesTableViewController *destinationViewController = (DevicesTableViewController *)segue.destinationViewController;
    destinationViewController.group = [self.groups objectAtIndex:indexPath.row];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.groups count]) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

#pragma mark - TextField delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[self.tableView convertPoint:CGPointZero fromView:textField]];
    if (indexPath.row < [self.groups count]) {
        Group *group = self.groups[indexPath.row];
        group.name = textField.text;
    }
}

@end
