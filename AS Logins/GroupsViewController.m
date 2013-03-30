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

@interface GroupsViewController ()

@property (nonatomic, strong) NSArray *groups;

@end

@implementation GroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateGroups];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    /*
    if ([self.groups count] == 0) {
        [Group groupWithName:@"Operations" inContext:self.managedObjectContext];
        [self updateGroups];
    }
     */
}

- (void)updateGroups {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
    NSError *error;
    // TODO: Handle error
    self.groups = [self.managedObjectContext executeFetchRequest:request error:&error];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView reloadData];
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
    }
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

@end
