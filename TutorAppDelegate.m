//
//  TutorAppDelegate.m
//  Tutor
//

#import "TutorAppDelegate.h"
#import "NSTimeIntervalToMMSSTransformer.h"
#import "NSStringToAttributedStringTransformer.h"
#import "VideoItem.h"
#import "NewsletterViewController.h"
#import "AppListItem.h"

static NSString* const RateURL = @"https://itunes.apple.com/us/app/tutor-for-apple-watch-2/id1132707060?ls=1&mt=8";
static NSString* const TroubleShootingURL = @"https://www.noteboomtutorials.com/contact-us/";
static NSString* const NoteFieldStringPreferenceKey = @"Notes";
static NSString* const CanSelectNextPrevItemChangedContext = @"CanSelectNextChangedContext";
static NSString* const NumOfTimesLaunchedPreferenceKey = @"NumOfTimesLaunchedPreferenceKey";
static NSString* const IsUserAgreedToReviewTheAppPreferenceKey = @"IsUserAgreedToReviewTheApp";
static NSString* const IsUserSubscribedToNewsletterPreferenceKey = @"IsUserSubscribedToNewsletter";

static NSInteger AskForReviewLaunchPeriod = 3;
static NSInteger AskForNewsletterSubscriptionLaunchPeriod = 4;
static BOOL AskForReviewFirstLaunch = NO;
static BOOL AskForNewsletterFirstLaunch = YES;

@implementation TutorAppDelegate

@synthesize preferencesWindow;

- (void) awakeFromNib
{
	[moviePlayer bind:@"videoFilePath" toObject:videoListArrayController withKeyPath:@"selection.systemPath" options:nil];
	[NSValueTransformer setValueTransformer:[[NSTimeIntervalToMMSSTransformer new] autorelease] forName:@"NSTimeIntervalToMMSSTransformer"];
	[NSValueTransformer setValueTransformer:[[NSStringToAttributedStringTransformer new] autorelease] forName:@"NSStringToAttributedStringTransformer"];
    if( [self isRunningUnderSnowLeopard] == NO ) {
        // we are under Lion or later, use native full screen
        const int NSWindowCollectionBehaviorFullScreenPrimary = 1 << 7;
        NSWindowCollectionBehavior behavior = [mainWindowController.normalWindow collectionBehavior];
        behavior |= NSWindowCollectionBehaviorFullScreenPrimary;
        [mainWindowController.normalWindow setCollectionBehavior: behavior];
    }
    [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"isShowVideoListInFullScreen" options:NSKeyValueObservingOptionNew context:nil];
    [preferencesWindow setLevel:NSFloatingWindowLevel];
    [videoListArrayController addObserver:self forKeyPath:@"canSelectNext" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:CanSelectNextPrevItemChangedContext];
    [videoListArrayController addObserver:self forKeyPath:@"canSelectPrevious" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:CanSelectNextPrevItemChangedContext];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newsletterCompleted:) name:NewsletterSubscriptionIsCompletedNotificationName object:nil];
    
    NSSortDescriptor* kindSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"kind" ascending:YES];
    NSSortDescriptor* dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"releaseDate" ascending:NO];
    [appListArrayController setSortDescriptors:[NSArray arrayWithObjects:kindSortDescriptor, dateSortDescriptor, nil]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[mainWindowController initPopupPanels];
    NSString* lastVideoFilePath = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastVideoFilePath"];
    NSNumber* lastVideoTime = [[NSUserDefaults standardUserDefaults]  valueForKey:@"lastVideoTime"];
    VideoItem* lastVideoItem = [videoList videoItemWithSystemPath:lastVideoFilePath];
    if( lastVideoTime != nil && lastVideoItem != nil ) {
        // resume from the last state
        [videoListArrayController setSelectedObjects:[NSArray arrayWithObject:lastVideoItem]];
        moviePlayer.currentTime = [lastVideoTime floatValue];
    }
    [appListModel downloadAppList];
    // total num of launches
    NSInteger currentLaunch = [[NSUserDefaults standardUserDefaults] integerForKey:NumOfTimesLaunchedPreferenceKey];
    currentLaunch += 1;
    [[NSUserDefaults standardUserDefaults] setInteger:currentLaunch forKey:NumOfTimesLaunchedPreferenceKey];
    NSLog(@"launch = %li", currentLaunch);

    BOOL isReviewed = [[NSUserDefaults standardUserDefaults] boolForKey:IsUserAgreedToReviewTheAppPreferenceKey];
    if( isReviewed == NO ) {
        // ask for review?
        if( ( currentLaunch > 1 && ( currentLaunch % AskForReviewLaunchPeriod == 0 ) ) ||
           ( currentLaunch == 1 && AskForReviewFirstLaunch ) )
        {
            self.isReviewDontAskHidden = NO;
            [reviewPopover showRelativeToRect:[reviewToolbarButton frame] ofView:reviewToolbarButton preferredEdge:NSMaxYEdge];
        }
    }
    
    BOOL isSubscribed = [[NSUserDefaults standardUserDefaults] boolForKey:IsUserSubscribedToNewsletterPreferenceKey];
    if( isSubscribed == NO ) {
        // ask to subscribe
        if( ( currentLaunch > 1 && ( currentLaunch % AskForNewsletterSubscriptionLaunchPeriod == 0 ) ) ||
           ( currentLaunch == 1 && AskForNewsletterFirstLaunch ) ) {
            self.isNewsletterDontAskHidden = NO;
            [newsletterPopover showRelativeToRect:[newsletterToolbarButton frame] ofView:newsletterToolbarButton preferredEdge:NSMaxYEdge];
        }
    }
}

- (void)applicationWillResignActive:(NSNotification *)aNotification
{
	// exit full screen if application is deactivated
	[self exitFullScreen:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}
     
- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [[NSUserDefaults standardUserDefaults] setValue:moviePlayer.videoFilePath forKey:@"lastVideoFilePath"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:moviePlayer.currentTime] forKey:@"lastVideoTime"];
}

- (void)windowWillClose:(NSNotification *)notification
{
    if( [notification object] == mainWindowController.normalWindow ) {
        [preferencesWindow performClose:self];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if( mainWindowController.isFullscreen == YES && [keyPath isEqualToString:@"isShowVideoListInFullScreen"] ) {
        // refresh left panel
        [mainWindowController.normalWindow enterFullScreenWithAnimationDuration:0.5f];
    }
    if( context == CanSelectNextPrevItemChangedContext ) {
        [prevNextToolbarSegmentedControl setEnabled:[videoListArrayController canSelectPrevious] forSegment:0];
        [prevNextToolbarSegmentedControl setEnabled:[videoListArrayController canSelectNext] forSegment:1];
    }
}

- (NSSize)window:(NSWindow *)window willUseFullScreenContentSize:(NSSize)proposedSize
{
    // leave a border around our full screen window
    //return NSMakeSize(proposedSize.width - 180, proposedSize.height - 100);
    NSSize idealWindowSize = NSMakeSize(proposedSize.width, proposedSize.height);
    
    // Constrain that ideal size to the available area (proposedSize).
    NSSize customWindowSize;
    customWindowSize.width  = MIN(idealWindowSize.width,  proposedSize.width);
    customWindowSize.height = MIN(idealWindowSize.height, proposedSize.height);
    
    // Return the result.
    return customWindowSize;
}

- (void)windowDidEnterFullScreen:(NSNotification *)notification
{
    mainWindowController.isFullscreen = YES;
    [mainWindowController.normalWindow enterFullScreenWithAnimationDuration:0.5f];
    mainWindowController.normalWindow.hideCursorWhenPopupIsHidden = NO;
}

- (void)windowDidExitFullScreen:(NSNotification *)notification
{
	mainWindowController.isFullscreen = NO;
    [mainWindowController.normalWindow exitFullScreenWithAnimationDuration:0.5f];
    mainWindowController.normalWindow.hideCursorWhenPopupIsHidden = NO;
}

- (void)doToggleFullScreen:(id)sender
{
    if( [self isRunningUnderSnowLeopard] == NO ) {
        // we are under Lion or later, use native full screen
        [mainWindowController.normalWindow toggleFullScreen:self];
    } else {
        // we are under SL
        mainWindowController.isFullscreen = !mainWindowController.isFullscreen;
    }
}

- (void)newsletterCompleted:(NSNotification*)notification
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IsUserSubscribedToNewsletterPreferenceKey];
    [newsletterPopover close];
}

- (IBAction) exitFullScreen:(id)sender
{
    if( [self isRunningUnderSnowLeopard] == NO ) {
        // we are under Lion or later, use native full screen
        if( ( [NSApp currentSystemPresentationOptions] & NSApplicationPresentationFullScreen ) != 0 ) {
            // in full screen mode
            [self doToggleFullScreen:self];
        }
    } else {
        if( mainWindowController.isFullscreen == YES ) {
            [self doToggleFullScreen:self];
        }
    }
}

- (IBAction) enterFullScreen:(id)sender;
{
    if( [self isRunningUnderSnowLeopard] == NO ) {
        // we are under Lion or later, use native full screen
        if( ( [NSApp currentSystemPresentationOptions] & NSApplicationPresentationFullScreen ) == 0 ) {
            // in non full screen mode
            [self doToggleFullScreen:self];
        }
    } else {
        if( mainWindowController.isFullscreen == NO ) {
            [self doToggleFullScreen:self];
        }
    }
}

- (IBAction) toggleFullScreen:(id)sender
{
    if( [self isRunningUnderSnowLeopard] == NO ) {
        [self doToggleFullScreen:sender];
    }
}

- (IBAction) startPlayback:(id)sender
{
	moviePlayer.isPlaying = YES;
}

- (IBAction) stopPlayback:(id)sender
{
	moviePlayer.isPlaying = NO;
}

- (IBAction) togglePlayPause:(id)sender
{
	if( moviePlayer.isPlaying == YES ) {
		[self stopPlayback:sender];
	} else {
		[self startPlayback:sender];
	}
}

- (IBAction) showAboutDialog:(id)sender
{
	NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:nil];
	[[NSApplication sharedApplication] orderFrontStandardAboutPanelWithOptions:options];
}

- (IBAction) showRate:(id)sender
{
    [reviewPopover close];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IsUserAgreedToReviewTheAppPreferenceKey];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:RateURL]];
}

- (IBAction) showHelp:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:TroubleShootingURL]];
}

- (IBAction) addNoteButtonPressed:(id)sender
{
    // old notes
    NSString* oldNotesString = [[NSUserDefaults standardUserDefaults] objectForKey:NoteFieldStringPreferenceKey];
    if( oldNotesString == nil ) {
        oldNotesString = @"";
    }
    if( [oldNotesString length] > 0 ) {
        oldNotesString = [oldNotesString stringByAppendingString:@"\n\n"];
    }
    // new note
    VideoItem* currentVideoItem = [videoList videoItemWithSystemPath:moviePlayer.videoFilePath];
    NSTimeIntervalToMMSSTransformer* transformer = [[[NSTimeIntervalToMMSSTransformer alloc] init] autorelease];
    NSString* currentTimeString = [transformer transformedValue:[NSNumber numberWithFloat:moviePlayer.currentTime]];
    NSString* newNoteString = [NSString stringWithFormat:@"-%@ (%@)\n", currentVideoItem.title, currentTimeString];
    NSString* newNotesString = [oldNotesString stringByAppendingString:newNoteString];
    [[NSUserDefaults standardUserDefaults] setObject:newNotesString forKey:NoteFieldStringPreferenceKey];
    [mainWindowController.normalWindow activateNotesField];
}

- (IBAction) emailNotesButtonPressed:(id)sender
{
    VideoItem* currentVideoItem = [videoList videoItemWithSystemPath:moviePlayer.videoFilePath];
    NSString* body = [mainWindowController.normalWindow notesFieldString];
    NSString* subject = [NSString stringWithFormat:@"'%@' notes", currentVideoItem.title];
    NSString* to = @"";
    
    NSString* encodedSubject = [NSString stringWithFormat:@"SUBJECT=%@", [subject stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString* encodedBody = [NSString stringWithFormat:@"BODY=%@", [body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString* encodedTo = [to stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* encodedURLString = [NSString stringWithFormat:@"mailto:%@?%@&%@", encodedTo, encodedSubject, encodedBody];
    NSURL* mailtoURL = [NSURL URLWithString:encodedURLString];
    [[NSWorkspace sharedWorkspace] openURL:mailtoURL];
}

- (IBAction) printNotesButtonPressed:(id)sender
{
    [mainWindowController.normalWindow printNotesField];
}

- (IBAction) prevNextToolbarButtonPressed:(id)sender
{
    int clickedSegment = [sender selectedSegment];
    int clickedSegmentTag = [[sender cell] tagForSegment:clickedSegment];
    if( clickedSegmentTag == 0 ) {
        // go left
        [videoListArrayController selectPrevious:self];
    } else {
        // go right
        [videoListArrayController selectNext:self];
    }
}

- (IBAction) shoppingCartButtonPressed:(id)sender
{
    if( shoppingCartPopover.shown == NO ) {
        [shoppingCartPopover showRelativeToRect:[sender frame] ofView:sender preferredEdge:NSMaxYEdge];
    } else {
        [shoppingCartPopover close];
    }
}

- (IBAction) newsletterButtonPressed:(id)sender
{
    if( newsletterPopover.shown == NO ) {
        self.isNewsletterDontAskHidden = YES;
        [newsletterPopover showRelativeToRect:[sender frame] ofView:sender preferredEdge:NSMaxYEdge];
    } else {
        [newsletterPopover close];
    }
}

- (IBAction) reviewButtonPressed:(id)sender
{
    if( reviewPopover.shown == NO ) {
        self.isReviewDontAskHidden = YES;
        [reviewPopover showRelativeToRect:[sender frame] ofView:sender preferredEdge:NSMaxYEdge];
    } else {
        [reviewPopover close];
    }
}


- (void) videoSelectedFromMenu:(id)sender
{
	VideoItem* selectedVideo = [sender representedObject];
	[videoListArrayController setSelectedObjects:[NSArray arrayWithObject:selectedVideo]];
}

- (void) menuWillOpen:(NSMenu*)menu
{
	if( menu == videosSubmenu ) {
		// delete all old items
		for( int i = [videosSubmenu numberOfItems] - 1; i >= 0 ; i-- ) {
			[videosSubmenu removeItemAtIndex:i];
		}
		// populating submenu with videos
		NSArray* videosArray = [videoListArrayController arrangedObjects];
		for( VideoItem* videoItem in videosArray ) {
			NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle:[videoItem title] action:@selector(videoSelectedFromMenu:) keyEquivalent:@""];
			[menuItem setRepresentedObject:videoItem];
			if( videoItem == [[videoListArrayController selectedObjects] lastObject] ) {
				// show selected item
				[menuItem setState:NSOnState];
			}
			[videosSubmenu addItem:menuItem];
		}
	}
}

- (BOOL) isRunningUnderSnowLeopard
{
    SInt32 macVersionMajor;
    SInt32 macVersionMinor;
    
    if( Gestalt( gestaltSystemVersionMajor, &macVersionMajor ) == noErr ) {
        if( Gestalt( gestaltSystemVersionMinor, &macVersionMinor ) == noErr ) {
            if( macVersionMajor > 10 || ( macVersionMajor == 10 && macVersionMinor >= 7 ) ) {
                return NO;
            }
        }
    }
    // report that we are under SL in case of any unclear situations 
    return YES;
}

- (BOOL) isAppInFullScreen
{
    if( [self isRunningUnderSnowLeopard] == NO ) {
        // we are under Lion or later, use native full screen
        return ( [NSApp currentSystemPresentationOptions] & NSApplicationPresentationFullScreen ) != 0;
    } else {
        return mainWindowController.isFullscreen;
    }
}

- (NSURL*)url:(NSURL*)sourceUrl byAppendingQueryString:(NSString *)queryString
{
    if (![queryString length]) {
        return sourceUrl;
    }
    
    NSString *URLString = [[NSString alloc] initWithFormat:@"%@%@%@", [sourceUrl absoluteString],
                           [sourceUrl query] ? @"&" : @"?", queryString];
    NSURL *theURL = [NSURL URLWithString:URLString];
    [URLString release];
    return theURL;
}

- (void) showAppInAppStore:(NSInteger)index
{
    if( index >= 0 && index < [[appListArrayController arrangedObjects] count] ) {
        AppListItem* item = [[appListArrayController arrangedObjects] objectAtIndex:index];
        NSURL* resultUrl = item.appStoreURL;
        resultUrl = [self url:resultUrl byAppendingQueryString:@"at=11lxtE&ct=macapp-watch-2"];
        [[NSWorkspace sharedWorkspace] openURL:resultUrl];
    }
}
@end
