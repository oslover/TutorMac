//
//  QTMovieView+NoResponder.m
//  Tutor
//

#import "QTMovieView+NoResponder.h"


@implementation QTMovieView(NoResponder)

- (BOOL)acceptsFirstResponder
{
	// do not want movie view to become first responder
	return NO;
}

@end