//
//  AppListModel.m
//  Tutor for Keynote
//
//  Created by Alex Khripunov on 27/03/14.
//  Copyright (c) 2014 Noteboom. All rights reserved.
//

#import "AppListModel.h"
#import "AppListItem.h"

static NSString* AppsLookupURLString = @"https://itunes.apple.com/lookup?id=384558310&entity=software";

@interface AppListModel()<NSURLDownloadDelegate>
@end

@implementation AppListModel

+ (AppListModel*)sharedAppListModel
{
    static dispatch_once_t onceToken;
    static AppListModel* sharedInstance = nil;
    dispatch_once( &onceToken, ^{
        sharedInstance = [[AppListModel alloc] init];
    });
    return sharedInstance;
}

- (NSString*)defaultAppListFilePath
{
    return [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"apps.list"]];
}

- (NSString*)iconFilePathForAppID:(NSString*)appid
{
    return [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"icon.%@.image", appid]];
}

- (void)downloadAppList
{
    self.isAppListDownloading = YES;
    // Create the request.
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:AppsLookupURLString]
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:60.0];
    
    // Create the connection with the request and start loading the data.
    NSURLDownload  *theDownload = [[NSURLDownload alloc] initWithRequest:theRequest
                                                                delegate:self];
    if (theDownload) {
        // Set the destination file.
        [theDownload setDestination:[self defaultAppListFilePath] allowOverwrite:YES];
    } else {
        // inform the user that the download failed.
    }
}


- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
    // Inform the user.
    NSLog(@"Download failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [[NSApp mainWindow] presentError:error];
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
    NSString* jsonFilePath = [self defaultAppListFilePath];
    NSLog(@"downloadDidFinish, %@", jsonFilePath);
    [self populateFromFile:jsonFilePath];
}

- (void)populateFromFile:(NSString*)filePath
{
    NSData* jsonData = [NSData dataWithContentsOfFile:filePath];
    NSError* error = nil;
    NSDictionary* result = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if( error ) {
        NSLog(@"JSON error = %@", error);
        [[NSApp delegate] presentError:error];
    }
    NSArray* items = result[@"results"];
    
    NSMutableArray* newAppList = [NSMutableArray array];
    for( NSDictionary* nextItem in items ) {
        NSString* title = nextItem[@"trackCensoredName"];
        NSString* iconURLString = nextItem[@"artworkUrl100"];
        NSString* description = nextItem[@"description"];
        NSString* appStoreURLString = nextItem[@"trackViewUrl"]; //nextItem[@"sellerUrl"];
        NSString* kind = nextItem[@"kind"];
        NSString* trackID = nextItem[@"trackId"];
        NSString* releaseDateString = nextItem[@"releaseDate"];
        
        if( iconURLString != nil && description != nil && appStoreURLString != nil && kind != nil ) {
            AppListItem* newItem = [[[AppListItem alloc] init] autorelease];
            newItem.title = title;
            newItem.itemDescription = description;
            newItem.appStoreURL = [NSURL URLWithString:appStoreURLString];
            if( [kind hasPrefix:@"mac"] ) {
                // mac app
                newItem.kind = @"Mac";
            } else {
                newItem.kind = @"iPhone/iPad";
            }
            newItem.releaseDate = [NSDate dateWithNaturalLanguageString:releaseDateString];
            
            [newAppList addObject:newItem];
            
            NSString* iconPath = [self iconFilePathForAppID:trackID];
            if( [[NSFileManager defaultManager] fileExistsAtPath:iconPath] ) {
                // file exists
                newItem.iconURL = [NSURL fileURLWithPath:iconPath];
            } else {
                //download icon
                NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:iconURLString]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:60.0];
                [NSURLConnection sendAsynchronousRequest:theRequest queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    dispatch_async( dispatch_get_main_queue(), ^{
                        [data writeToFile:iconPath atomically:YES];
                        newItem.iconURL = [NSURL fileURLWithPath:iconPath];
                    });
                }];
   
            }
        }
    }
    self.appList = newAppList;
}

@end
