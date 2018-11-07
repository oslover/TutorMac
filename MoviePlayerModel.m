//
//  MoviePlayerModel.m
//  Tutor
//

#import "MoviePlayerModel.h"

static const NSTimeInterval MovieDataRefreshTimeout = 0.3;
static const int DefaultTimeScale = 10000;
static NSString* AVPlayerRateChangedContext = @"AVPlayerRateChangedContext";

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// private interface
@interface MoviePlayerModel()

@property (readwrite, retain) AVPlayer* avPlayer;
@property (readwrite, assign) NSTimeInterval totalTime;
@property (readwrite, assign) BOOL isPlayerFinished;
@property (readwrite, assign) BOOL isSeeking;

// movie data methods
- (void) refreshMovieData;
// timer methods
- (void)timerFired:(NSTimer*)theTimer;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MoviePlayerModel

@synthesize videoFilePath, avPlayer, isPlaying, currentTime, totalTime;

- (void) awakeFromNib
{
    [self addObserver:self forKeyPath:@"avPlayer.rate" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:AVPlayerRateChangedContext];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieDidEndHandler) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    timer = [[NSTimer scheduledTimerWithTimeInterval:MovieDataRefreshTimeout target:self selector:@selector(timerFired:) userInfo:nil repeats:YES] retain];

}

- (id) init
{
	if( self = [super init] ) {
		return self;
	} else {
		return nil;
	}
}

- (void) dealloc
{
	[timer release];
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if( context == AVPlayerRateChangedContext ) {
        [self movieRateDidChangeHandler];
    }
}

- (void) movieDidEndHandler
{
	self.isPlaying = NO;
    self.isPlayerFinished = YES;
}

- (void) movieRateDidChangeHandler
{
    if( self.isSeeking == NO ) {
        [self refreshMovieData];
    }
}

- (void) createAVPlayer
{
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:videoFilePath]];
    if( playerItem != nil ) {
        self.avPlayer = [AVPlayer playerWithPlayerItem:playerItem];
        self.currentTime = 0;
    } else {
        self.avPlayer = nil;
        NSLog(@"Unable to init AVPlayerItem with: %@", videoFilePath);
    }
}

- (void) setIsPlaying:(BOOL)newValue
{
	if( isPlaying != newValue ) {
		if( isPlaying ) {
			[self.avPlayer pause];
		} else {
            if( self.isPlayerFinished ) {
                // start from beginning
                self.currentTime = 0;
                self.isPlayerFinished = NO;
            }
			[self.avPlayer play];
		}
		isPlaying = newValue;
	}
}

- (NSTimeInterval) NSTimeIntervalFromCMTime:(CMTime)cmTime
{
	NSTimeInterval time = CMTimeGetSeconds(cmTime);
    return time;
}

- (void) refreshMovieData
{
    if (self.avPlayer == nil || self.avPlayer.status == AVPlayerStatusUnknown) {
        return;
    }
    
	[self willChangeValueForKey:@"currentTime"];
	currentTime = [self NSTimeIntervalFromCMTime:[self.avPlayer currentTime]];
	[self didChangeValueForKey:@"currentTime"];

	[self willChangeValueForKey:@"isPlaying"];
	isPlaying = [self.avPlayer rate];
	[self didChangeValueForKey:@"isPlaying"];
	
    if (self.avPlayer.status == AVPlayerStatusReadyToPlay) {
        self.totalTime = [self NSTimeIntervalFromCMTime:[self.avPlayer.currentItem.asset duration]];
    }
}

#pragma mark timer methods

- (void)timerFired:(NSTimer*)theTimer
{
    if( self.isSeeking == NO ) {
        [self refreshMovieData];
    }
}

#pragma mark get/set methods

- (void) setCurrentTime:(NSTimeInterval)newTime
{
    if( self.avPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay ) {
        self.isSeeking = YES;
        self.isPlayerFinished = NO;
        BOOL isPlayedBeforeSeek = self.isPlaying;
        // pause playback
        self.isPlaying = NO;
        CMTime cmTime = CMTimeMakeWithSeconds(newTime, DefaultTimeScale);
        [self.avPlayer seekToTime:cmTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            if( isPlayedBeforeSeek ) {
                // restart playback
                [self performSelector:@selector(setIsPlaying:) withObject:[NSNumber numberWithBool:YES] afterDelay:0];
            }
            self.isSeeking = NO;
        }];
    }
}

- (void) setVideoFilePath:(NSString*)path
{
    self.isPlayerFinished = NO;
	self.isPlaying = NO;
	[videoFilePath release];
	videoFilePath = [path copy];
	[self createAVPlayer];
	[self refreshMovieData];
}

@end
