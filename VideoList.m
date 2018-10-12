//
//  VideoList.m
//  Tutor
//

#import "VideoList.h"

@implementation VideoList

@synthesize videoList;

- (id) init
{
	if( self = [super init] ) {
		videoList = [[NSMutableArray alloc] init];
		return self;
	} else {
		return nil;
	}
}

- (void) dealloc
{
	[videoList release];
	[super dealloc];
}

- (void) awakeFromNib
{
	// populating list of videos from videos.plist
	NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"videos" ofType:@"plist"];
	NSPropertyListFormat format;
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
	NSString* errorString;
	NSDictionary *plistDictionary = (NSDictionary *)[NSPropertyListSerialization
										   propertyListFromData:plistXML
										   mutabilityOption:NSPropertyListMutableContainersAndLeaves
										   format:&format
										   errorDescription:&errorString];
	if( plistDictionary ) {
		NSArray* itemsDictionaryArray = [plistDictionary objectForKey:@"VideosList"];
		// iterate through all items
		for( NSDictionary* itemDictionary in itemsDictionaryArray ) {
			NSString* bundlePath = [itemDictionary valueForKey:@"BundlePath"];
			if( [bundlePath length] > 0 ) {
				NSString* systemPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:bundlePath];
				VideoItem* item = [[VideoItem alloc] initWithPath:systemPath];
				item.title = [itemDictionary valueForKey:@"Title"];
				item.itemDescription = [itemDictionary valueForKey:@"Description"];
				[[self mutableArrayValueForKey:@"videoList"] addObject:item];
				[item release];
			} else {
				// plist content error
				NSLog( @"There are error in plist's content: %@", plistPath );
			}
		}
	} else {
		NSLog( @"Error reading plist: %@, format: %@", errorString, [NSNumber numberWithInteger:format]);
	}
}

- (VideoItem*) videoItemWithSystemPath:(NSString*)path
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"systemPath == %@", path];
    NSArray* filteredArray = [videoList filteredArrayUsingPredicate:predicate];
    return [filteredArray lastObject];
}

@end
