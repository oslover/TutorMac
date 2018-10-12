//
//  TutorMovieView.h
//  Tutor for iMovie
//
//  Created by oDesk on 12/12/13.
//  Copyright (c) 2013 Noteboom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MoviePlayerModel.h"

@interface TutorMovieView : NSView

@property(readwrite, assign) IBOutlet MoviePlayerModel* moviePlayerModel;

@end
