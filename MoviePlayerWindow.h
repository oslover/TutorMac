//
//  WindowWithFloatingPanel.h
//  Tutor
//

#import <Cocoa/Cocoa.h>
#import "TutorMovieView.h"

@interface MoviePlayerWindow : NSWindow {
	// shared movie view
	IBOutlet TutorMovieView* movieView;
	// container for shared movie view
	IBOutlet NSView* movieViewContainer;
	// popup panel view with video controls
	IBOutlet NSView* popupView;
	// child window w popup panel view
	NSWindow* popupWindow;
	// mouse tracking area
	NSTrackingArea* area;
}

// activates current player window
- (void) activate;
- (void) initPopupPanel;
- (void) showPopupWindow;
- (void) showAndAutoHidePopupWindow;
- (void) hidePopupWindow;

@end
