//
//  DevicesTableViewController.m
//  AS Logins
//
//  Created by Robbie Clarken on 17/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "DevicesTableViewController.h"
#import "DeviceViewController.h"
#import "DeviceCell.h"
#import "Device.h"

static NSString *DevicesKey = @"devices";
static NSString *DeviceCellIdentifier = @"DeviceCellIdentifier";

@interface DevicesTableViewController () <DeviceViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *editManagedObjectContext;

@end

@implementation DevicesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Devices";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showNewDeviceViewController)];
    [self.tableView registerClass:[DeviceCell class] forCellReuseIdentifier:DeviceCellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)showNewDeviceViewController {
    [self.group.managedObjectContext save:nil];
    
    Device *device = (Device *)[NSEntityDescription insertNewObjectForEntityForName:@"Device" inManagedObjectContext:self.group.managedObjectContext];
    device.group = self.group;
    DeviceViewController *deviceViewController = [[DeviceViewController alloc] initWithStyle:UITableViewStyleGrouped];
    deviceViewController.device = device;
    [deviceViewController setEditing:YES animated:NO];
    deviceViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    deviceViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:deviceViewController];
    [self presentViewController:navigationController animated:YES completion:^{}];
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
        
        DeviceViewController *newDeviceViewController = [[DeviceViewController alloc] initWithStyle:UITableViewStyleGrouped];
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
    DeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:DeviceCellIdentifier forIndexPath:indexPath];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.group.managedObjectContext save:nil];
    Device *device = self.group.devices[self.tableView.indexPathForSelectedRow.row];
    DeviceViewController *destinationViewController = [[DeviceViewController alloc] initWithStyle:UITableViewStyleGrouped];
    destinationViewController.device = device;
    [self.navigationController pushViewController:destinationViewController animated:YES];
}

@end
