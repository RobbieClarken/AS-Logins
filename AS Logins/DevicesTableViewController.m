//
//  DevicesTableViewController.m
//  AS Logins
//
//  Created by Robbie Clarken on 17/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "DevicesTableViewController.h"
#import "EditDeviceViewController.h"
#import "Device.h"

static NSString *DevicesKey = @"devices";

@interface DevicesTableViewController () <EditLoginViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *editManagedObjectContext;

@end

@implementation DevicesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[EditDeviceViewController class]]) {
        [self.group.managedObjectContext save:nil];
        
        NSManagedObjectContext *editDeviceManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        editDeviceManagedObjectContext.parentContext = self.group.managedObjectContext;
        NSError *error;
        Group *editDeviceGroup = (Group *)[editDeviceManagedObjectContext existingObjectWithID:self.group.objectID error:&error];
        if (error) {
            // TODO: Handle error
            NSLog(@"%s %@", __PRETTY_FUNCTION__, error.localizedDescription);
        }
        Device *device = [NSEntityDescription insertNewObjectForEntityForName:@"Device" inManagedObjectContext:editDeviceManagedObjectContext];
        NSMutableOrderedSet *devices = [editDeviceGroup mutableOrderedSetValueForKey:DevicesKey];
        [devices addObject:device];
        EditDeviceViewController *destinationViewController = (EditDeviceViewController *)segue.destinationViewController;
        destinationViewController.managedObjectContext = editDeviceManagedObjectContext;
        destinationViewController.delegate = self;
        destinationViewController.device = device;
    }
}

#pragma mark - Login edit delegate

- (void)editDeviceTableViewController:(EditDeviceViewController *)editDeviceViewController didFinishWithSave:(BOOL)save {
    if (save) {
        NSError *error;
        [editDeviceViewController.managedObjectContext save:&error];
        if (error) {
            NSLog(@"Unresolved error in %s: %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
            abort();
        }
        [self.group.managedObjectContext save:&error];
        if (error) {
            NSLog(@"Unresolved error in %s: %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
            abort();
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.group.devices count]-1 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
