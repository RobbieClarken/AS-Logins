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
        NSMutableOrderedSet *devices = [editDeviceGroup mutableOrderedSetValueForKey:@"devices"];
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
            NSLog(@"%s %@", __PRETTY_FUNCTION__, error.localizedDescription);
        }
        [self.group.managedObjectContext save:&error];
        if (error) {
            NSLog(@"%s %@", __PRETTY_FUNCTION__, error.localizedDescription);
        }
        [self.tableView reloadData];
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

@end
