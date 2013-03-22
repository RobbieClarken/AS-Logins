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

@interface GroupsViewController ()

@property (nonatomic, strong) NSArray *groups;

@end

@implementation GroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateGroups];
    if ([self.groups count] == 0) {
        [Group groupWithName:@"Operations" inContext:self.managedObjectContext];
        [self updateGroups];
    }
}

- (void)updateGroups {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Group"];
    NSError *error;
    // TODO: Handle error
    self.groups = [self.managedObjectContext executeFetchRequest:request error:&error];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GroupCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [self.groups[indexPath.row] name];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    DevicesTableViewController *destinationViewController = (DevicesTableViewController *)segue.destinationViewController;
    destinationViewController.group = [self.groups objectAtIndex:indexPath.row];
}

@end
