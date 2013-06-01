//
//  SettingsViewController.m
//  AS Logins
//
//  Created by Robbie Clarken on 31/05/13.
//  Copyright (c) 2013 Robbie Clarken. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsButtonCell.h"
#import "LockViewController.h"
#import "CodeHelper.h"
#import "SyncManager.h"

static NSString *SettingsButtonCellIdentifier = @"Cell";

@interface SettingsViewController () <LockViewControllerDelegate>

@property (weak, nonatomic) SettingsButtonCell *syncButtonCell;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[SettingsButtonCell class] forCellReuseIdentifier:SettingsButtonCellIdentifier];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self.delegate action:@selector(dismissSettingsViewController:)];
}

- (void)dismissLockView {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (NSString *)lastSynchronizedString {
    NSTimeInterval timeSinceLastSync = -[[SyncManager lastSynchronized] timeIntervalSinceNow];
    NSInteger time;
    NSString *unit;
    if (timeSinceLastSync < 60) {
        time = (NSInteger)timeSinceLastSync;
        unit = @"second";
    } else if (timeSinceLastSync < 3600) {
        time = (NSInteger)(timeSinceLastSync/60.0f);
        unit = @"minute";
    } else if (timeSinceLastSync < 86400) {
        time = (NSInteger)(timeSinceLastSync/3600.0f);
        unit = @"hour";
    } else {
        time = (NSInteger)(timeSinceLastSync/86400.0f);
        unit = @"day";
    }
    unit = [self pluralise:unit ifNotUnity:time];
    return [NSString stringWithFormat:@"Last synchronized %i %@ ago", time, unit];
}

- (NSString *)pluralise:(NSString *)word ifNotUnity:(NSInteger)number {
    if (number == 1) {
        return word;
    }
    return [word stringByAppendingString:@"s"];
}

- (void)sync {
    [self.syncButtonCell startActivity];
    __weak SettingsViewController *weakSelf = self;
    [[SyncManager sharedSyncManager] syncWithCompetionBlock:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.syncButtonCell stopActivity];
            if (success) {
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
            }
        });
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            // Security
            return 1;
            break;
        case 1:
            // Synchronize
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Security";
        case 1:
            return @"Cloud";
        default:
            return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 1:
            return [self lastSynchronizedString];
        default:
            return nil;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            // Security
            switch (indexPath.row) {
                case 0: {
                    SettingsButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingsButtonCellIdentifier forIndexPath:indexPath];
                    cell.titleLabel.text = @"Change Passcode";
                    return cell;
                }
            }
            break;
        case 1:
            // Synchronize
            switch (indexPath.row) {
                case 0: {
                    SettingsButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingsButtonCellIdentifier forIndexPath:indexPath];
                    cell.titleLabel.text = @"Synchronize Now";
                    self.syncButtonCell = cell;
                    return cell;
                }
            }
            break;
    }
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            // Security
            switch (indexPath.row) {
                case 0: {
                    LockViewController *lockViewController = [[LockViewController alloc] init];
                    lockViewController.settingCode = YES;
                    lockViewController.delegate = self;
                    
                    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:lockViewController];
                    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                    lockViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissLockView)];
                    [self presentViewController:navigationController animated:YES completion:^{}];
                    break;
                }
            }
            break;
        case 1:
            // Synchronize
            switch (indexPath.row) {
                case 0: {
                    [self sync];
                    break;
                }
            }
            break;
        break;
    }
}

#pragma mark - LockViewControllerDelegate

- (void)lockView:(LockViewController *)lockView finishedSettingCodeWithCodeHash:(NSUInteger)codeHash {
    [CodeHelper setSecuredCodeFromCodeHash:codeHash];
    [self dismissLockView];
}

- (void)lockView:(LockViewController *)lockView finishedUnlocking:(BOOL)success {
    // Not used
}

- (BOOL)checkCodeHash:(NSUInteger)codeHash {
    // Not used
    return NO;
}

@end
