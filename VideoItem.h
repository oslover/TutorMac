//
//  VideoItem.h
//  Tutor
//

#import <Cocoa/Cocoa.h>


@interface VideoItem : NSObject {
	// absolute path to a mov file
	NSString* systemPath;
	// title of the video displayed to the user
	NSString* title;
	// description of this video
	NSString* description;
}

@property (readonly, copy) NSString* systemPath;
@property (readwrite, copy) NSString* title;
@property (readwrite, copy) NSString* itemDescription;

- (id) initWithPath:(NSString*)path;

@end
