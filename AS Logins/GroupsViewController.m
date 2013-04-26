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
#import "AppDelegate.h"

static NSUInteger GroupPositionStep = 0x10000;
static NSString *CellIdentifier = @"GroupCell";

@interface GroupsViewController () <UITextFieldDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) BOOL cellInsertedDueToEditOfEmptyTextField;
@property (nonatomic, strong) NSIndexPath *indexPathOfEditingCell;

@property (nonatomic) BOOL changeIsUserDriven;

@end

@implementation GroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Groups";
    [self.tableView registerClass:[GroupCell class] forCellReuseIdentifier:CellIdentifier];
    self.fetchedResultsController.delegate = self;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.cellInsertedDueToEditOfEmptyTextField = NO;
    [self addRefreshControl];
}

- (void)addRefreshControl {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Sync"];
    [refreshControl addTarget:self action:@selector(synchronizeWithServer) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

- (void)synchronizeWithServer {
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Syncing..."];

    [(AppDelegate *)[UIApplication sharedApplication].delegate initiateSync];
    
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Sync"];
    [self.refreshControl endRefreshing];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
    request.predicate = [NSPredicate predicateWithFormat:@"toDelete == NO"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES]];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    [_fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"Unresolved error in %s: %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
        abort();
    }
    return _fetchedResultsController;
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
            NSIndexPath *lastGroupIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
            Group *group = [self.fetchedResultsController objectAtIndexPath:lastGroupIndexPath];
            positionInteger = [group.position integerValue] + GroupPositionStep;
        }
        self.cellInsertedDueToEditOfEmptyTextField = YES;
        [Group groupWithName:@"" atPosition:[NSNumber numberWithInt:positionInteger] inContext:self.managedObjectContext];
    }
}

- (NSUInteger)numberOfGroups {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[0];
    return [sectionInfo numberOfObjects];
}

#pragma mark - Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
    if (self.cellInsertedDueToEditOfEmptyTextField) {
        GroupCell *cell = (GroupCell *)[self.tableView cellForRowAtIndexPath:self.indexPathOfEditingCell];
        [cell.textField becomeFirstResponder];
        self.indexPathOfEditingCell = nil;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    switch(type) {
        case NSFetchedResultsChangeInsert: {
            if (self.cellInsertedDueToEditOfEmptyTextField) {
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
            break;
        case NSFetchedResultsChangeUpdate:
            // If cellInsertedDueToEditOfEmptyTextField is YES then this is only
            // being called because the textField was dismissed in what was
            // the empty group cell. The update of this cell will have already
            // have been triggered by the NSFetchedResultsChangeInsert change.
            if (self.cellInsertedDueToEditOfEmptyTextField) {
                self.cellInsertedDueToEditOfEmptyTextField = NO;
            } else {
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];                
            }
            break;
        case NSFetchedResultsChangeMove:
            if (!self.changeIsUserDriven) {
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                self.changeIsUserDriven = NO;
            }
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {    
    if (self.editing) {
        return [self numberOfGroups] + 1;
    } else {
        return [self numberOfGroups];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (indexPath.row < [self numberOfGroups]) {
        Group *group = (Group *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.textField.text = group.name;
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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self numberOfGroups]) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleInsert;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Group *group = (Group *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        group.toDelete = @YES;
        group.lastModifiedDate = [NSDate date];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DevicesTableViewController *devicesTableViewController = [[DevicesTableViewController alloc] initWithStyle:UITableViewStylePlain];
    devicesTableViewController.group = (Group *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:devicesTableViewController animated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (proposedDestinationIndexPath.row == [self numberOfGroups]) {
        return [NSIndexPath indexPathForRow:[self numberOfGroups]-1 inSection:proposedDestinationIndexPath.section];
    }
    return proposedDestinationIndexPath;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row < [self numberOfGroups];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if ([sourceIndexPath isEqual:destinationIndexPath]) {
        return;
    }
    Group *movingGroup = (Group *)[self.fetchedResultsController objectAtIndexPath:sourceIndexPath];
    Group *destinationGroup = (Group *)[self.fetchedResultsController objectAtIndexPath:destinationIndexPath];
    NSUInteger newPositionInteger;
    if (destinationIndexPath.row == 0) {
        newPositionInteger = [destinationGroup.position integerValue]/2;
    } else if (destinationIndexPath.row == [self numberOfGroups]-1) {
        newPositionInteger = [destinationGroup.position integerValue] + GroupPositionStep;
    } else {
        // Find the index in self.groups of the group that will be
        // before the moved group once the move is complete.
        NSUInteger earlierGroupIndex = destinationIndexPath.row-1;
        // If we have moved the group from below the destination row will
        // be one too low because the moved cell is not counted.
        if (sourceIndexPath.row < destinationIndexPath.row) {
            earlierGroupIndex += 1;
        }
        NSIndexPath *earlierIndexPath = [NSIndexPath indexPathForRow:earlierGroupIndex inSection:sourceIndexPath.section];
        NSIndexPath *latterIndexPath = [NSIndexPath indexPathForRow:earlierGroupIndex+1 inSection:sourceIndexPath.section];
        Group *earlierGroup = (Group *)[self.fetchedResultsController objectAtIndexPath:earlierIndexPath];
        Group *latterGroup = (Group *)[self.fetchedResultsController objectAtIndexPath:latterIndexPath];
        newPositionInteger = ([earlierGroup.position integerValue] + [latterGroup.position integerValue])/2;
    }
    self.changeIsUserDriven = YES;
    movingGroup.lastModifiedDate = [NSDate date];
    movingGroup.position = [NSNumber numberWithInteger:newPositionInteger];
}

#pragma mark - TextField delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[self.tableView convertPoint:CGPointZero fromView:textField]];
    if (indexPath.row < [self numberOfGroups]) {
        Group *group = (Group *)[self.fetchedResultsController objectAtIndexPath:indexPath];
        group.name = textField.text;
        group.lastModifiedDate = [NSDate date];
    }
}

@end
