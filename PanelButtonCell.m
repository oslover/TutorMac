//
//  PanelButtonCell.m
//  Tutor
//

#import "PanelButtonCell.h"


@implementation PanelButtonCell

- (void) awakeFromNib
{
	[self setHighlightsBy:([self highlightsBy] & ~NSContentsCellMask)];
}

- (void)drawImage:(NSImage*)image withFrame:(NSRect)frame inView:(NSView *)controlView
{
    if( [self isHighlighted] ) {
        [image drawInRect:frame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil];
    } else {
        [image drawInRect:frame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.8 respectFlipped:YES hints:nil];
    }
}

@end
