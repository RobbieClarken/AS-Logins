//
//  SettingsViewController.m
//  AS Logins
//
//  Created by Robbie Clarken on 31/05/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsButtonCell.h"

static NSString *CellIdentifier = @"Cell";

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[SettingsButtonCell class] forCellReuseIdentifier:CellIdentifier];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self.delegate action:@selector(dismissSettingsViewController:)];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingsButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    switch (indexPath.row) {
        case 0:
            cell.titleLabel.text = @"Change Passcode";
            break;
        default:
            abort();
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     [self.navigationController pushViewController:detailViewController animated:YES];
    */
}

@end
