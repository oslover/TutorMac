//
//  NewsletterViewController.m
//  Tutor for Keynote
//
//  Created by Alex Khripunov on 27/03/14.
//  Copyright (c) 2014 Noteboom. All rights reserved.
//

#import "NewsletterViewController.h"
#import "ChimpKit.h"

NSString* NewsletterSubscriptionIsCompletedNotificationName = @"NewsletterSubscriptionIsCompletedNotificationName";

static NSString* MailChimpApiKey = @"29eba35d149d18c04f2cdf596782be5c-us2";

@interface NewsletterViewController()<NSTextFieldDelegate>

@end

@implementation NewsletterViewController

- (void)awakeFromNib
{
    self.isSubscribeAvailable = NO;
    self.isSubscribeInProgress = NO;
    self.emailTextField.delegate = self;
}

- (void)controlTextDidChange:(NSNotification *)notification
{
    if( [[self.emailTextField stringValue] length] > 0 )  {
        self.isSubscribeAvailable = YES;
    }
    else {
        self.isSubscribeAvailable = NO;
    }
}



- (void)subscribeUsingMailChimp:(void(^)(NSString* subscribedAddress, NSError* error))completionHandler
{
    NSString* emailString = self.emailTextField.stringValue;
    NSString* nameString = self.nameTextField.stringValue;

    [[ChimpKit sharedKit] setApiKey:MailChimpApiKey];

    NSDictionary *params = @{@"id": @"d3391fc66a",
                             @"email": @{@"email": emailString ? emailString : @""},
                             @"merge_vars": @{@"MMERGE1": nameString ? nameString : @"MacApp-watchOS-3"}
                             };

    [[ChimpKit sharedKit] callApiMethod:@"lists/subscribe" withParams:params andCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        if( error ) {
            if( completionHandler ) {
                dispatch_async( dispatch_get_main_queue(), ^{
                    completionHandler( nil, error );
                });
            }
        } else {
            NSError *parseError = nil;
            id responseObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            if ([responseObj isKindOfClass:[NSDictionary class]]) {
                NSString* errorStr = responseObj[@"error"];
                NSString* email = [responseObj objectForKey:@"email"];
                if( errorStr == nil ) {
                    //Successfully subscribed email address
                    if( completionHandler ) {
                        dispatch_async( dispatch_get_main_queue(), ^{
                            completionHandler( email, nil );
                        });
                    }
                } else {
                    NSError* error = [NSError errorWithDomain:@"com.noteboomtutorials.macapp" code:0 userInfo:@{NSLocalizedDescriptionKey:errorStr}];
                    if( completionHandler ) {
                        dispatch_async( dispatch_get_main_queue(), ^{
                            completionHandler( nil, error );
                        });
                    }
                }
            }
        }
    }];
}

- (IBAction)subscribeButtonPressed:(id)sender
{
    self.isSubscribeInProgress = YES;
    
    void(^completionHandler)(NSString *subscribedAddress, NSError *error) = ^(NSString *subscribedAddress, NSError *error) {
        if( error == nil ) {
            NSLog(@"Successfully subscribed %@", subscribedAddress);
            [[NSNotificationCenter defaultCenter] postNotificationName:NewsletterSubscriptionIsCompletedNotificationName object:nil];
        } else {
            NSLog(@"Something went wrong: %@", error);
            [self presentError:error];
        }
        self.isSubscribeInProgress = NO;
    };
    
/*    [self subscribeUsingCampaignMonitor:^(NSString *subscribedAddress, NSError *error) {
        completionHandler( subscribedAddress, error );
    }];*/
    [self subscribeUsingMailChimp:^(NSString *subscribedAddress, NSError *error) {
        completionHandler( subscribedAddress, error );
    }];
}

@end
