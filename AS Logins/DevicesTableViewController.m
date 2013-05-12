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
#import "Device+Create.h"
#import "AppDelegate.h"

// TODO: Prevent device cell appearing before modal view is presented

static NSString *DeviceCellIdentifier = @"DeviceCellIdentifier";

@interface DevicesTableViewController () <DeviceViewControllerDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation DevicesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Devices";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showNewDeviceViewController)];
    [self.tableView registerClass:[DeviceCell class] forCellReuseIdentifier:DeviceCellIdentifier];
    self.fetchedResultsController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Device"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"group == %@ AND toDelete == NO", self.group];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.group.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    // TODO: Handle error
    [_fetchedResultsController performFetch:nil];
    return _fetchedResultsController;
}

- (NSUInteger)numberOfDevices {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[0];
    return sectionInfo.numberOfObjects;
}

- (Device *)deviceForIndexPath:(NSIndexPath *)indexPath {
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (void)showNewDeviceViewController {
    [self.group.managedObjectContext save:nil];
    Device *device = [Device deviceForGroup:self.group inContext:self.group.managedObjectContext];
    // HACK: Flag as deleted so the login doesn't appear straight away
    device.toDelete = @YES;
    DeviceViewController *deviceViewController = [[DeviceViewController alloc] initWithStyle:UITableViewStyleGrouped];
    deviceViewController.device = device;
    [deviceViewController setEditing:YES animated:NO];
    deviceViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    deviceViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:deviceViewController];
    [self presentViewController:navigationController animated:YES completion:^{}];
}

#pragma mark - fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    switch(type) {
        case NSFetchedResultsChangeInsert: {
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

#pragma mark - device view delegate

- (void)deviceViewController:(DeviceViewController *)editDeviceViewController didFinishWithSave:(BOOL)save {
    if (save) {
        NSError *error;
        editDeviceViewController.device.toDelete = @NO;
        [self.group.managedObjectContext save:&error];
        if (error) {
            NSLog(@"Unresolved error in %s: %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
            abort();
        }
        [(AppDelegate *)[UIApplication sharedApplication].delegate initiateSync:^(BOOL success) {}];
        DeviceViewController *newDeviceViewController = [[DeviceViewController alloc] initWithStyle:UITableViewStyleGrouped];
        newDeviceViewController.device = editDeviceViewController.device;
        [self.navigationController pushViewController:newDeviceViewController animated:NO];
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{}];
    } else {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            [self.group.managedObjectContext performBlock:^{
                [self.group.managedObjectContext rollback];
            }];
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfDevices];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:DeviceCellIdentifier forIndexPath:indexPath];
    Device *device = [self deviceForIndexPath:indexPath];
    cell.textLabel.text = device.name;
    cell.detailTextLabel.text = device.hostname;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Device *device = [self deviceForIndexPath:indexPath];
        device.toDelete = @YES;
        NSError *error;
        [self.group.managedObjectContext save:&error];
        if (error) {
            NSLog(@"Unresolved error in %s: %@, %@", __PRETTY_FUNCTION__, error, [error userInfo]);
            abort();
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.group.managedObjectContext save:nil];
    Device *device = [self deviceForIndexPath:indexPath];
    DeviceViewController *destinationViewController = [[DeviceViewController alloc] initWithStyle:UITableViewStyleGrouped];
    destinationViewController.device = device;
    [self.navigationController pushViewController:destinationViewController animated:YES];
}

@end
