//
//  TutorMovieView.m
//  Tutor for iMovie
//
//  Created by oDesk on 12/12/13.
//  Copyright (c) 2013 Noteboom. All rights reserved.
//

#import "TutorMovieView.h"
#import <AVFoundation/AVFoundation.h>

static NSString* AVPlayerChangedContext = @"AVPlayerChangedContext";

@interface TutorMovieView()

@property(readwrite, retain) AVPlayerLayer* playerLayer;

@end

@implementation TutorMovieView

- (void)awakeFromNib
{
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:nil];
    self.playerLayer.backgroundColor = [[NSColor blackColor] CGColor];
    [self setLayer:self.playerLayer];
    [self setWantsLayer:YES];
    [self.moviePlayerModel addObserver:self forKeyPath:@"avPlayer" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:AVPlayerChangedContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if( context == AVPlayerChangedContext ) {
        self.playerLayer.player = self.moviePlayerModel.avPlayer;
    }
}

@end
