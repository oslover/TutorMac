//
//  TutorMainWindowController.h
//  Tutor
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "TutorNormalWindow.h"
#import "TutorMovieView.h"

@interface TutorMainWindowController : NSObject {
	// normal window
	IBOutlet TutorNormalWindow* normalWindow;
    IBOutlet NSView* normalscreenPopupView;
	// fullscreen popup view
	IBOutlet NSView* fullscreenPopupView;
	// shared movie view
	IBOutlet TutorMovieView* movieView;
    // video list view
    IBOutlet NSTableView* videoListTableView;
	// is in full screen mode?
	BOOL isFullscreen;
	// saved presentation options
	SystemUIMode savedUIMode;
	SystemUIOptions savedUIOptions;
    NSRect savedRect;
}

@property (readwrite) BOOL isFullscreen;
@property (readonly) TutorNormalWindow* normalWindow;

- (void) initPopupPanels;

@end
