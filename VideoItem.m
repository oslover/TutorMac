//
//  VideoItem.m
//  Tutor
//

#import "VideoItem.h"

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// private intervace
@interface VideoItem()
@property (readwrite, copy) NSString* systemPath;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation VideoItem

@synthesize systemPath, title, description;

- (id) initWithPath:(NSString*)path
{
	if( self = [super init] ) {
		self.systemPath = path;
		return self;
	} else {
		return nil;
	}
}

@end
