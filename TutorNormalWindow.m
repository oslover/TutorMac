//
//  TutorMainWindow.m
//  Tutor
//

#import "TutorNormalWindow.h"
#import "TutorAppDelegate.h"

static const NSInteger VideoPanelMinWidth = 282;
static const NSInteger VideoPanelMaxWidth = 282;
static const NSInteger VideoPanelMinWidthInFullScreen = 282;
static const NSInteger VideoPanelMaxWidthInFullScreen = 282;
static const NSInteger NoteFieldMinHeight = 230;
static const NSInteger NoteFieldMaxHeight = 285;

static const NSTimeInterval FullScreenResizeAnimationDuration = 0.3f;

//static const BOOL HideLeftPanelInFullScreen = NO;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TutorNormalWindow

#pragma mark Split views
- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex
{
    if( splitView == horizontalSplitView ) {
        return YES;
    } else {
        return NO;
    }
}


- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex
{
    BOOL isShowVideoListInFullScreen = [[NSUserDefaults standardUserDefaults] boolForKey:@"isShowVideoListInFullScreen"];
//    if( ( [NSApp currentSystemPresentationOptions] & NSApplicationPresentationFullScreen ) != 0 ) {
    if( [[NSApp delegate] isAppInFullScreen] ) {
        // in full screen mode
        if( isShowVideoListInFullScreen == NO ) {
            // override in full screen mode to allow collapsing of left panel
            return 0;
        } else {
            if( splitView == horizontalSplitView ) {
                return VideoPanelMinWidthInFullScreen;
            }
            if( splitView == verticalSplitView ) {
                return splitView.bounds.size.height - NoteFieldMaxHeight;
            }
       }
    } else {
        // not in full screen mode
        if( splitView == horizontalSplitView ) {
            return VideoPanelMinWidth;
        }
        if( splitView == verticalSplitView ) {
            return splitView.bounds.size.height - NoteFieldMaxHeight;
        }
    }
 	return proposedMax;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex
{
    BOOL isShowVideoListInFullScreen = [[NSUserDefaults standardUserDefaults] boolForKey:@"isShowVideoListInFullScreen"];
//    if( ( [NSApp currentSystemPresentationOptions] & NSApplicationPresentationFullScreen ) != 0 ) {
    if( [[NSApp delegate] isAppInFullScreen] ) {
        // in full screen mode
        if( isShowVideoListInFullScreen == NO ) {
            // override in full screen mode to allow collapsing of left panel
            return CGFLOAT_MAX;
        } else {
            if( splitView == horizontalSplitView ) {
                return VideoPanelMaxWidthInFullScreen;
            }
            if( splitView == verticalSplitView ) {
                return splitView.bounds.size.height - NoteFieldMinHeight;
            }
        }
     } else {
        // not in full screen mode
        if( splitView == horizontalSplitView ) {
            return VideoPanelMaxWidth;
        }
        if( splitView == verticalSplitView ) {
            return splitView.bounds.size.height - NoteFieldMinHeight;
        }
    }
    return proposedMax;
}

- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize
{
	if( splitView == horizontalSplitView ) {
		NSSize splitViewSize = [splitView frame].size;
		
		// video list is fixed in width when window is resized
		NSSize videoListViewSize = [leftSplitSubview frame].size;
		videoListViewSize.height = splitViewSize.height;
		
		NSSize videoPlayerViewSize;
		videoPlayerViewSize.height = splitViewSize.height;
		videoPlayerViewSize.width = splitViewSize.width - [splitView dividerThickness] - videoListViewSize.width;
		
		[leftSplitSubview setFrameSize:videoListViewSize];
		[rightSplitSubview setFrameSize:videoPlayerViewSize];
        [splitView adjustSubviews];
	}
	if( splitView == verticalSplitView ) {
		NSSize splitViewSize = [splitView frame].size;
	
		// bottom subview is fixed in height when window is resized
		NSSize bottomSubviewSize = [bottomSplitSubview frame].size;
		bottomSubviewSize.width = splitViewSize.width;

		NSSize topSubviewSize;// = [topSplitSubview frame].size;
		topSubviewSize.width = splitViewSize.width;
		topSubviewSize.height = splitViewSize.height - [splitView dividerThickness] - bottomSubviewSize.height;
		
		[topSplitSubview setFrameSize:topSubviewSize];
		[bottomSplitSubview setFrameSize:bottomSubviewSize];
        [bottomSplitSubview setFrameOrigin:NSMakePoint(0, topSubviewSize.height + [splitView dividerThickness])];
	}
}

- (void) hidePopupWindow
{
	// in fullscreen mode we need to hide mouse cursor when poppup panle is hidden
	[NSCursor setHiddenUntilMouseMoves:self.hideCursorWhenPopupIsHidden];
	[super hidePopupWindow];
}

- (void) setSplitterPosition: (CGFloat) newPosition
{	
	NSView *view0 = leftSplitSubview;
	NSView *view1 = rightSplitSubview;
	
	NSRect view0TargetFrame = NSMakeRect( view0.frame.origin.x, view0.frame.origin.y, newPosition, view0.frame.size.height);
	NSRect view1TargetFrame = NSMakeRect( newPosition + horizontalSplitView.dividerThickness, view1.frame.origin.y, NSMaxX(view1.frame) - newPosition - horizontalSplitView.dividerThickness, view1.frame.size.height);
	
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:FullScreenResizeAnimationDuration];
	[[view0 animator] setFrame: view0TargetFrame];
	[[view1 animator] setFrame: view1TargetFrame];
	[NSAnimationContext endGrouping];
}

- (void) enterFullScreenWithAnimationDuration:(NSTimeInterval)duration
{
    BOOL isShowVideoListInFullScreen = [[NSUserDefaults standardUserDefaults] boolForKey:@"isShowVideoListInFullScreen"];
    if( isShowVideoListInFullScreen == NO ) {
        // hide left panel and divider
        [self setSplitterPosition:0];        
    } else {
        CGFloat position = [self splitView:horizontalSplitView constrainMaxCoordinate:0 ofSubviewAt:0];
        [self setSplitterPosition:position];
    }
/*    // hide bottom bar
 	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:FullScreenResizeAnimationDuration];
    [[horizontalSplitView animator] setFrame:[self.contentView bounds]];
	[NSAnimationContext endGrouping];*/
}

- (void) exitFullScreenWithAnimationDuration:(NSTimeInterval)duration
{
    BOOL isShowVideoListInFullScreen = [[NSUserDefaults standardUserDefaults] boolForKey:@"isShowVideoListInFullScreen"];
    if( isShowVideoListInFullScreen == NO ) {
        // show left panel and divider
        [self setSplitterPosition:VideoPanelMinWidth];
    } else {
        CGFloat position = [self splitView:horizontalSplitView constrainMinCoordinate:0 ofSubviewAt:0];
        [self setSplitterPosition:position];
    }
/*    // show bottom bar
    NSRect newRect = [self.contentView bounds];
    CGFloat bottomBarHeight = [self contentBorderThicknessForEdge:NSMinYEdge];
    newRect.size.height -= bottomBarHeight;
    newRect.origin.y += bottomBarHeight;
 	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:FullScreenResizeAnimationDuration];
    [[horizontalSplitView animator] setFrame:newRect];
	[NSAnimationContext endGrouping];*/
}

// ESC key or Cmd-period while in fullscreen mode
- (IBAction)cancelOperation:(id)sender
{
	[[self delegate] performSelector:@selector(exitFullScreen:) withObject:self];
}

- (void) activateNotesField
{
    [[notesField window] makeFirstResponder:notesField];
    [notesField scrollRangeToVisible:[notesField selectedRange]];
}

- (NSView*) printableView
{
    NSTextView*    printView;
    
    // CREATE THE PRINT VIEW
    // width is based on the actual size and orientation of the printable area of the page.
    printView = [[[NSTextView alloc] initWithFrame:[[NSPrintInfo sharedPrintInfo] imageablePageBounds]] autorelease];
    [printView setVerticallyResizable:YES];
    [printView setHorizontallyResizable:NO];

    // ADD THE TEXT
    [[printView textStorage] beginEditing];
    // Add the body text
    [[printView textStorage] appendAttributedString:[notesField textStorage]];
    [[printView textStorage] endEditing];
    
    // Resize the print view to fit the added text
    [printView sizeToFit];
    
    return printView;
}

- (void) printNotesField
{
    NSPrintOperation* printOperation;
    
    // This will scale the view to fit the page without centering it.
    // It would be better to specify these default settings when
    // the document is created instead of in the print method.
    [[NSPrintInfo sharedPrintInfo] setHorizontalPagination:NSFitPagination];
    [[NSPrintInfo sharedPrintInfo] setHorizontallyCentered:NO];
    [[NSPrintInfo sharedPrintInfo] setVerticallyCentered:NO];
    
    // Setup the print operation with the print info and view
    printOperation = [NSPrintOperation printOperationWithView:[self printableView] printInfo:[NSPrintInfo sharedPrintInfo]];
    [printOperation runOperationModalForWindow:self delegate:nil didRunSelector:NULL contextInfo:NULL];
}

- (NSString*) notesFieldString
{
    return [notesField string];
}

@end
