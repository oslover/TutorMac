//
//  TutorMainWindowController.m
//  Tutor
//

#import "TutorMainWindowController.h"
#import "TutorNormalWindow.h"
#import "TutorAppDelegate.h"

@implementation TutorMainWindowController

@synthesize normalWindow;

- (void) awakeFromNib
{
    // no bottom bar
    [normalWindow setContentBorderThickness:0.0 forEdge:NSMinYEdge];
    [normalWindow setAutorecalculatesContentBorderThickness:NO forEdge:NSMinYEdge];
}

- (void) initPopupPanels
{
	[normalWindow initPopupPanel];
	[normalWindow activate];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	// show popup window when new video is selected
	[normalWindow showAndAutoHidePopupWindow];
    [videoListTableView scrollRowToVisible:[videoListTableView selectedRow]];
}

- (void) setIsFullscreen:(BOOL)newValue
{
	if(isFullscreen == newValue ) {
		return;
	}
    if( [[NSApp delegate] isRunningUnderSnowLeopard] == YES ) {
        // we are using built in full screen support under Lion or later
        // and have to do it manually for SL
        if( self.isFullscreen == YES ) {
            // go to window state
            // set previous presentation options
            isFullscreen = newValue;
            self.normalWindow.hideCursorWhenPopupIsHidden = NO;
            SetSystemUIMode( savedUIMode, savedUIOptions);
            NSUInteger currentStyleMask = [self.normalWindow styleMask];
            currentStyleMask &= ~NSBorderlessWindowMask;
            currentStyleMask |= NSTitledWindowMask;
            [self.normalWindow setStyleMask:currentStyleMask];
            [self.normalWindow setFrame:savedRect display:YES animate:NO];
            [self.normalWindow exitFullScreenWithAnimationDuration:0.5f];
        } else {
            isFullscreen = newValue;
            self.normalWindow.hideCursorWhenPopupIsHidden = NO;
            // Hide the dock and menu bar, saving previous presentation options
            GetSystemUIMode( &savedUIMode, &savedUIOptions );
            SetSystemUIMode( kUIModeAllHidden, kUIOptionAutoShowMenuBar);
            savedRect = [self.normalWindow frame];
            // go to full screen state
            NSRect screenRect = [[self.normalWindow screen] frame];
            NSUInteger currentStyleMask = [self.normalWindow styleMask];
            currentStyleMask |= NSBorderlessWindowMask; // without border
            currentStyleMask &= ~NSTitledWindowMask; // without title
            [self.normalWindow setStyleMask:currentStyleMask];
            [self.normalWindow setFrame:screenRect display:YES animate:NO];
            [self.normalWindow enterFullScreenWithAnimationDuration:0.5f];
       }
    } else {
        isFullscreen = newValue;
    }
}

- (BOOL) isFullscreen
{
    return isFullscreen;
}

@end
