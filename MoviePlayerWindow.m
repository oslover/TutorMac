//
//  WindowWithFloatingPanel.m
//  Tutor
//

#import "MoviePlayerWindow.h"

static const NSTimeInterval PopupShowTimeInSeconds = 2.5f;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// private interface
@interface MoviePlayerWindow()

- (void) addTrackingArea;
- (NSWindow*) createPopupWindow;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation MoviePlayerWindow

- (void) awakeFromNib
{
	// notifications from movie subview
	[movieViewContainer setPostsFrameChangedNotifications:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieViewFrameChanged:) name:NSViewFrameDidChangeNotification object:movieViewContainer];
}

- (void) dealloc
{
	[area release];
	[popupWindow release];
	[super dealloc];
}

- (BOOL) acceptsMouseMovedEvents
{
	return YES;
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)close
{
	// close child window
	[popupWindow close];
	[super close];
}

- (void) addTrackingArea
{
	// add area to get mouseModved events
	area = [[NSTrackingArea alloc] initWithRect:[[self contentView] frame] options:NSTrackingMouseMoved|NSTrackingActiveInKeyWindow owner:self userInfo:nil];
	[[self contentView] addTrackingArea:area];
}

- (void) removeTrackingArea
{
	// remove area to get mouseModved events
	[[self contentView] removeTrackingArea:area];
	[area release];
	area = nil;
}

- (NSRect) popupWindowRect
{
    // the rect of the popup window in screen coordinates
    NSRect popupWindowRect = [[self contentView] convertRect:[movieViewContainer bounds] fromView:movieViewContainer];
    NSPoint newPopupWindowRectOrigin = [self convertRectToScreen:NSMakeRect(popupWindowRect.origin.x, popupWindowRect.origin.y, 0, 0)].origin;
    popupWindowRect.origin = newPopupWindowRectOrigin;
    popupWindowRect.size.height = [popupView frame].size.height;
    return popupWindowRect;
}

- (NSWindow*) createPopupWindow
{
	if( popupWindow == nil ) {
		// create popup window
		popupWindow = [[NSWindow alloc] initWithContentRect:[self popupWindowRect] styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
		NSColor* backgroundColor = [NSColor blackColor];
		backgroundColor = [backgroundColor colorWithAlphaComponent:0.6];
		[popupWindow setBackgroundColor:backgroundColor];
		[popupWindow setOpaque:NO];
		[popupWindow setAlphaValue:0];
		[popupWindow setReleasedWhenClosed:NO];
		// add panel view
		[[popupView retain] autorelease];  // in case the superview has the only retain
		[popupView removeFromSuperviewWithoutNeedingDisplay];
		[[popupWindow contentView] addSubview:popupView];
		[popupView setFrame:[[popupWindow contentView] bounds]];
		// add created window as a child 
		[self addChildWindow:popupWindow ordered:NSWindowAbove];
	}
	return popupWindow;
}

- (void) showPopupWindow
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidePopupWindow) object:nil];
	[[popupWindow animator] setAlphaValue:1];
	[popupWindow makeKeyAndOrderFront:self];
}

- (void) hidePopupWindow
{
	[[popupWindow animator] setAlphaValue:0];
}

- (void) showAndAutoHidePopupWindow
{
	[self showPopupWindow];
	[self performSelector:@selector(hidePopupWindow) withObject:nil afterDelay:PopupShowTimeInSeconds];
}

- (void) mouseMoved:(NSEvent*)theEvent
{
	NSRect movieContainerRect = [[self contentView] convertRect:[movieViewContainer bounds] fromView:movieViewContainer];
	
	NSPoint mouseLocation = [theEvent locationInWindow];
	
	// show panel if mouse pointer within movie
	if( NSPointInRect( mouseLocation, movieContainerRect ) ) {
		[self showPopupWindow];
	}
	// hide panel after interval if mouse is outside of panel
    if( NSPointInRect( [self convertRectToScreen:NSMakeRect(mouseLocation.x, mouseLocation.y, 0, 0)].origin, [self popupWindowRect] ) == NO ) {
		[self performSelector:@selector(hidePopupWindow) withObject:nil afterDelay:PopupShowTimeInSeconds];
	}
}

- (void)setFrame:(NSRect)windowFrame display:(BOOL)displayView
{
	// if new frame is set we need to reposition popupWindow
	[self removeTrackingArea];
	[super setFrame:windowFrame display:displayView];
	[self addTrackingArea];
	[popupWindow setFrame:[self popupWindowRect] display:displayView];
}

- (void) movieViewFrameChanged:(NSNotification*)notification
{
	// if new movie subview frame is set we need to reposition popupWindow
	if( [notification object] == movieViewContainer ) {
		[popupWindow setFrame:[self popupWindowRect] display:YES];
	}
}

- (void) activate
{
	// grab movie view upon activation
	[NSCursor setHiddenUntilMouseMoves:NO];
	[[movieView retain] autorelease];  // in case the superview has the only retain
	[movieView removeFromSuperviewWithoutNeedingDisplay];
	[movieViewContainer addSubview:movieView];
	[movieView setFrame:[movieViewContainer bounds]];
	[self showPopupWindow];
	[self performSelector:@selector(hidePopupWindow) withObject:nil afterDelay:PopupShowTimeInSeconds];
}

- (void) initPopupPanel
{
	[self createPopupWindow];
	[self setAcceptsMouseMovedEvents:YES];
}

- (void)keyDown:(NSEvent *)event
{
	NSString* eventChars = [event characters];
	if( [eventChars rangeOfString:@" "].location != NSNotFound ) {
		// play/pause movie when space bar is pressed
		[[self delegate] performSelector:@selector(togglePlayPause:) withObject:self];
	} else {
		[super keyDown:event];
	}
}

@end
