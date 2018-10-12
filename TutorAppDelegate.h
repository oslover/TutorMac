//
//  TutorAppDelegate.h
//  Tutor
//

#import <Cocoa/Cocoa.h>
#import "MoviePlayerModel.h"
#import "TutorMainWindowController.h"
#import "VideoList.h"
#import "AppListModel.h"

@interface TutorAppDelegate : NSObject {
    NSWindow* preferencesWindow;
    IBOutlet VideoList* videoList;
    IBOutlet AppListModel* appListModel;
	IBOutlet MoviePlayerModel* moviePlayer;
	IBOutlet NSArrayController* videoListArrayController;
	IBOutlet NSArrayController* appListArrayController;
	IBOutlet TutorMainWindowController* mainWindowController;
	IBOutlet NSMenu* videosSubmenu;
    IBOutlet NSSegmentedControl* prevNextToolbarSegmentedControl;
    IBOutlet NSPopover* shoppingCartPopover;
    IBOutlet NSPopover* newsletterPopover;
    IBOutlet NSPopover* reviewPopover;
    IBOutlet NSControl* reviewToolbarButton;
    IBOutlet NSControl* newsletterToolbarButton;
}

@property (assign) IBOutlet NSWindow *preferencesWindow;
@property(assign) BOOL isReviewDontAskHidden;
@property(assign) BOOL isNewsletterDontAskHidden;

- (IBAction) enterFullScreen:(id)sender;
- (IBAction) exitFullScreen:(id)sender;
- (IBAction) toggleFullScreen:(id)sender;
- (IBAction) startPlayback:(id)sender;
- (IBAction) stopPlayback:(id)sender;
- (IBAction) togglePlayPause:(id)sender;

- (IBAction) showAboutDialog:(id)sender;
- (IBAction) showRate:(id)sender;
- (IBAction) showHelp:(id)sender;

- (IBAction) addNoteButtonPressed:(id)sender;
- (IBAction) emailNotesButtonPressed:(id)sender;
- (IBAction) printNotesButtonPressed:(id)sender;

- (IBAction) prevNextToolbarButtonPressed:(id)sender;

- (IBAction) shoppingCartButtonPressed:(id)sender;
- (IBAction) newsletterButtonPressed:(id)sender;
- (IBAction) reviewButtonPressed:(id)sender;

- (BOOL) isRunningUnderSnowLeopard;
- (BOOL) isAppInFullScreen;
- (void) showAppInAppStore:(NSInteger)index;

@end
