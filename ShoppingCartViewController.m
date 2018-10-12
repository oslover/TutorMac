//
//  ShoppingCartPopoverViewController.m
//  Tutor for Keynote
//
//  Created by Alex Khripunov on 27/03/14.
//  Copyright (c) 2014 Noteboom. All rights reserved.
//

#import "ShoppingCartViewController.h"
#import "TutorAppDelegate.h"

@interface ShoppingCartViewController ()

@end

@implementation ShoppingCartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (BOOL)tableView:(NSTableView *)tableView shouldShowCellExpansionForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return NO;
}

- (IBAction)viewInAppStoreButtonPressed:(id)sender
{
    [[NSApp delegate] showAppInAppStore:[self.tableView clickedRow]];
}

@end
