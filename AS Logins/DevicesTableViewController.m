//
//  DevicesTableViewController.m
//  AS Logins
//
//  Created by Robbie Clarken on 17/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "DevicesTableViewController.h"
#import "DeviceViewController.h"
#import "Device.h"

static NSString *DevicesKey = @"devices";

@interface DevicesTableViewController () <DeviceViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *editManagedObjectContext;

@end

@implementation DevicesTableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DeviceViewController *destinationViewController;
    [self.group.managedObjectContext save:nil];
    Device *device;
    if ([segue.identifier isEqualToString:@"AddDevice"]) {
        destinationViewController = (DeviceViewController *)[(UINavigationController *)segue.destinationViewController topViewController];
        device = [NSEntityDescription insertNewObjectForEntityForName:@"Device" inManagedObjectContext:self.group.managedObjectContext];
        device.group = self.group;
        destinationViewController.delegate = self;
    } else if ([segue.identifier isEqualToString:@"ShowDevice"]) {
        destinationViewController = (DeviceViewController *)segue.destinationViewController;
        device = self.group.devices[self.tableView.indexPathForSelectedRow.row];
    }
    destinationViewController.device = device;
    // If adding a new device, default to editing mode
    [destinationViewController setEditing:[segue.identifier isEqualToString:@"AddDevice"] animated:NO];
}

#pragma mark - device view delegate

- (void)deviceViewController:(DeviceViewController *)editDeviceViewController didFinishWithSave:(BOOL)save {
    if (save) {
        NSError *error;
        [self.group.managedObjectContext save:&error];
        if (error) {
            NSLog(@"Unresolved error in %s: %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
            abort();
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.group.devices count]-1 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        Device *device = [self.group.devices lastObject];
        DeviceViewController *newDeviceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DeviceDetailView"];
        newDeviceViewController.device = device;
        [self.navigationController pushViewController:newDeviceViewController animated:NO];
    } else {
        [self.group.managedObjectContext rollback];
    }
    [self.presentedViewController dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.group.devices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"LoginCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Device *device = [self.group.devices objectAtIndex:indexPath.row];
    cell.textLabel.text = device.name;
    cell.detailTextLabel.text = device.hostname;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableOrderedSet *devices = [self.group mutableOrderedSetValueForKey:DevicesKey];
        [devices removeObjectAtIndex:indexPath.row];
        NSError *error;
        [self.group.managedObjectContext save:&error];
        if (error) {
            NSLog(@"Unresolved error in %s: %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
            abort();
        }
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
