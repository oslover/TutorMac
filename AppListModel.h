//
//  AppListModel.h
//  Tutor for Keynote
//
//  Created by Alex Khripunov on 27/03/14.
//  Copyright (c) 2014 Noteboom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppListModel : NSObject

+ (AppListModel*)sharedAppListModel;

@property(readwrite, retain) NSArray* appList;
@property(assign) BOOL isAppListDownloading;

- (void)downloadAppList;

@end
