//
//  NewsletterViewController.h
//  Tutor for Keynote
//
//  Created by Alex Khripunov on 27/03/14.
//  Copyright (c) 2014 Noteboom. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString* NewsletterSubscriptionIsCompletedNotificationName;

@interface NewsletterViewController : NSViewController

@property(assign) IBOutlet NSTextField* emailTextField;
@property(assign) IBOutlet NSTextField* nameTextField;
@property(assign) BOOL isSubscribeAvailable;
@property(assign) BOOL isSubscribeInProgress;

- (IBAction)subscribeButtonPressed:(id)sender;

@end
