//
//  TutorFullScreenWindow.m
//  Tutor
//

#import "TutorFullScreenWindow.h"

@implementation TutorFullScreenWindow

- (id) initWithQTMovieView:(QTMovieView*)_movieView withPopupView:(NSView*)_popupView
{
	NSRect screenRect = [[[_movieView window] screen] frame];
	if( self = [super initWithContentRect:screenRect styleMask:NSBorderlessWindowMask	backing:NSBackingStoreBuffered defer:NO] ) {
		[self setBackgroundColor:[NSColor blackColor]];
		movieView = _movieView;
		popupView = _popupView;
		movieViewContainer = [self contentView];
		return self;
	} else {
		return nil; 
	}
}

// ESC key or Cmd-period while in fullscreen mode
- (IBAction)cancelOperation:(id)sender
{
	[[self delegate] performSelector:@selector(exitFullScreen:) withObject:self];
}

- (void) hidePopupWindow
{
	// in fullscreen mode we need to hide mouse cursor when poppup panle is hidden
	[NSCursor setHiddenUntilMouseMoves:YES];
	[super hidePopupWindow];
}

@end
