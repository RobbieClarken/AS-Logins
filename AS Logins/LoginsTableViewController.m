//
//  LoginsTableViewController.m
//  AS Logins
//
//  Created by Robbie Clarken on 17/03/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "LoginsTableViewController.h"
#import "EditLoginViewController.h"
#import "Group.h"
#import "Device.h"

@interface LoginsTableViewController () <EditLoginViewControllerDelegate>

@property (nonatomic, strong) NSArray *groups;
@property (nonatomic, strong) UIManagedDocument *localDatabase;

@end

@implementation LoginsTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.groups = @[];
    /*
    [DatabaseHelper openDatabaseUsingBlock:^(UIManagedDocument *database) {
        self.localDatabase = database;
    }];
    */
}

- (Device *)deviceForIndexPath:(NSIndexPath *)indexPath {
    Group *group = self.groups[indexPath.section];
    return group.devices[indexPath.row];
}

#pragma mark - Login edit delegate

- (void)editLoginTableViewControllerDidCancel:(EditLoginViewController *)editLoginViewController {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:^{}];
}

- (void)editLoginTableViewControllerDidSave:(EditLoginViewController *)editLoginViewController {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.groups count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[(Group *)self.groups[section] devices] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"LoginCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Device *device = [self deviceForIndexPath:indexPath];
    cell.textLabel.text = device.name;
    cell.detailTextLabel.text = device.hostname;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [(Group *)self.groups[section] name];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[EditLoginViewController class]]) {
        EditLoginViewController *destinationViewController = (EditLoginViewController *)segue.destinationViewController;
        destinationViewController.delegate = self;
    }
}

@end
