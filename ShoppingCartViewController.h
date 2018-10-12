//
//  ShoppingCartPopoverViewController.h
//  Tutor for Keynote
//
//  Created by Alex Khripunov on 27/03/14.
//  Copyright (c) 2014 Noteboom. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ShoppingCartViewController : NSViewController

@property(assign) IBOutlet NSTableView* tableView;

- (IBAction)viewInAppStoreButtonPressed:(id)sender;

@end
