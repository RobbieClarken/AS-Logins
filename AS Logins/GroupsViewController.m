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
    self.groups = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Unresolved error in %s: %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
        abort();
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
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
    if (editing) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
    [super setEditing:editing animated:animated];
    [self.tableView reloadData];
}

- (void)cancelButtonPressed:(UIBarButtonItem *)sender {
    [self.view endEditing:YES];
    [self.managedObjectContext rollback];
    [self updateGroups];
    [self setEditing:NO animated:YES];
}

- (void)editedEmptyGroup:(UITextField *)textField {
    [textField removeTarget:self action:@selector(editedEmptyGroup:) forControlEvents:UIControlEventEditingChanged];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[self.tableView convertPoint:CGPointZero fromView:textField]];
    if (indexPath.row == [self.tableView numberOfRowsInSection:indexPath.section]-1) {
        NSUInteger positionInteger;
        if (indexPath.row == 0) {
            positionInteger = GroupPositionStep;
        } else {
            positionInteger = [[(Group *)self.groups.lastObject position] integerValue] + GroupPositionStep;
        }
        [Group groupWithName:@"" atPosition:[NSNumber numberWithInt:positionInteger] inContext:self.managedObjectContext];
        [self updateGroups];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
        GroupCell *cell = (GroupCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.stayEditable = YES;
        [self updateEditingStyleIndicators];
        cell.stayEditable = NO;
    }
}

- (void)updateEditingStyleIndicators {
    self.tableView.editing = NO;
    self.tableView.editing = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    DevicesTableViewController *destinationViewController = (DevicesTableViewController *)segue.destinationViewController;
    destinationViewController.group = [self.groups objectAtIndex:indexPath.row];
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
    cell.showsReorderControl = YES;
    cell.textField.delegate = self;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableView numberOfRowsInSection:indexPath.section] > 1;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row < [self.groups count];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.groups count]) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.managedObjectContext deleteObject:self.groups[indexPath.row]];
        [self updateGroups];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    //[self.view endEditing:YES];
    if (proposedDestinationIndexPath.row == [self.groups count]) {
        return [NSIndexPath indexPathForRow:[self.groups count]-1 inSection:proposedDestinationIndexPath.section];
    }
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if ([sourceIndexPath isEqual:destinationIndexPath]) {
        return;
    }
    Group *movingGroup = self.groups[sourceIndexPath.row];
    NSUInteger newPositionInteger;
    if (destinationIndexPath.row == 0) {
        newPositionInteger = [[(Group *)self.groups[0] position] integerValue]/2;
    } else if (destinationIndexPath.row == [self.groups count]-1) {
        newPositionInteger = [[(Group *)[self.groups lastObject] position] integerValue] + GroupPositionStep;
    } else {
        // Find the index in self.groups of the group that will be
        // before the moved group once the move is complete.
        NSUInteger earlierGroupIndex = destinationIndexPath.row-1;
        // If we have moved the group from below the destination row will
        // be one too low because the moved cell is not counted.
        if (sourceIndexPath.row < destinationIndexPath.row) {
            earlierGroupIndex += 1;
        }
        Group *earlierGroup = (Group *)self.groups[earlierGroupIndex];
        Group *latterGroup = (Group *)self.groups[earlierGroupIndex+1];
        newPositionInteger = ([earlierGroup.position integerValue] + [latterGroup.position integerValue])/2;
    }
    movingGroup.position = [NSNumber numberWithInteger:newPositionInteger];
    [self updateGroups];
    // Reindex the groups to prevent position collisions.
    NSUInteger positionInteger = 0;
    for (Group *group in self.groups) {
        positionInteger += GroupPositionStep;
        group.position = [NSNumber numberWithInteger:positionInteger];
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
