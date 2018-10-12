//
//  MoviePlayerModel.h
//  Tutor
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>

@interface MoviePlayerModel : NSObject {
	// path to a video file
	NSString* videoFilePath;
	// object that represent playable data from videoFilePath file
	AVPlayer* avPlayer;
	// playing video is in progress?
	BOOL isPlaying;
	// data update timer
	NSTimer* timer;
	
	// current video time
	NSTimeInterval currentTime;
	// total video time
	NSTimeInterval totalTime;
}

@property (nonatomic, readwrite, copy) NSString* videoFilePath;
@property (readonly, retain) AVPlayer* avPlayer;
@property (nonatomic, readwrite) BOOL isPlaying;
@property (nonatomic, readwrite, assign) NSTimeInterval currentTime;
@property (readonly, assign) NSTimeInterval totalTime;

@end
