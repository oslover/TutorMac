//
//  VideoList.h
//  Tutor
//

#import <Cocoa/Cocoa.h>
#import "VideoItem.h"


@interface VideoList : NSObject {
	NSMutableArray* videoList;
}

@property (readonly, retain) NSArray* videoList;

- (VideoItem*) videoItemWithSystemPath:(NSString*)path;

@end
