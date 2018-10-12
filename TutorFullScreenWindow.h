//
//  TutorFullScreenWindow.h
//  Tutor
//

#import <Cocoa/Cocoa.h>
#import "MoviePlayerWindow.h"

@interface TutorFullScreenWindow : MoviePlayerWindow {

}

- (id) initWithQTMovieView:(QTMovieView*)_movieView withPopupView:(NSView*)_popupView;

@end
