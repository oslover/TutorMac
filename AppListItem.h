//
//  AppListItem.h
//  Tutor for Keynote
//
//  Created by Alex Khripunov on 27/03/14.
//  Copyright (c) 2014 Noteboom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppListItem : NSObject

@property(readwrite, retain) NSURL* iconURL;
@property(readwrite, retain) NSString* title;
@property(readwrite, retain) NSString* itemDescription;
@property(readwrite, retain) NSURL* appStoreURL;
@property(readwrite, retain) NSString* kind;
@property(readwrite, retain) NSDate* releaseDate;

@end
