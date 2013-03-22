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

@end

@implementation DevicesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    Device *device;
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        device = [NSEntityDescription insertNewObjectForEntityForName:@"Device" inManagedObjectContext:self.group.managedObjectContext];
        NSMutableOrderedSet *devices = [self.group mutableOrderedSetValueForKey:@"devices"];
        [devices addObject:device];
        NSError *error;
        [self.group.managedObjectContext save:&error];
        if (error) {
            NSLog(@"%s %@", __PRETTY_FUNCTION__, error.localizedDescription);
        }
    }
    if ([segue.destinationViewController isKindOfClass:[EditDeviceViewController class]]) {
        EditDeviceViewController *destinationViewController = (EditDeviceViewController *)segue.destinationViewController;
        destinationViewController.delegate = self;
        destinationViewController.device = device;
    }
}

#pragma mark - Login edit delegate

- (void)editDeviceTableViewControllerDidCancel:(EditDeviceViewController *)editDeviceViewController {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:^{}];
    //TODO: Tidy up added device
}

- (void)editDeviceTableViewControllerDidSave:(EditDeviceViewController *)editDeviceViewController {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
        NSError *error;
        [self.group.managedObjectContext save:&error];
        if (error) {
            NSLog(@"%s %@", __PRETTY_FUNCTION__, error.localizedDescription);
        }
        //dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        //});
    }];
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
