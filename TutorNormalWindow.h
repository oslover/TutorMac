//
//  TutorMainWindow.h
//  Tutor
//

#import <Cocoa/Cocoa.h>
#import "MoviePlayerWindow.h"

@interface TutorNormalWindow : MoviePlayerWindow {
	// split views/subviews
	IBOutlet NSSplitView* horizontalSplitView;
	IBOutlet NSSplitView* verticalSplitView;
	IBOutlet NSView* leftSplitSubview;
	IBOutlet NSView* rightSplitSubview;
	IBOutlet NSView* topSplitSubview;
	IBOutlet NSView* bottomSplitSubview;
    IBOutlet NSTextView* notesField;
}

@property(readwrite) BOOL hideCursorWhenPopupIsHidden;

// NSSplitView delegate methods
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex;
- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex;
- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize;

- (void) enterFullScreenWithAnimationDuration:(NSTimeInterval)duration;
- (void) exitFullScreenWithAnimationDuration:(NSTimeInterval)duration;

- (void) activateNotesField;
- (void) printNotesField;
- (NSString*) notesFieldString;

@end
