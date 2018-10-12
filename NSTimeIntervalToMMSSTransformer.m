//
//  NSTimeIntervalToMMSSTransformer.m
//  Tutor
//

#import "NSTimeIntervalToMMSSTransformer.h"

@implementation NSTimeIntervalToMMSSTransformer

+ (Class)transformedValueClass
{
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)value {
    if(value != nil) {
		NSTimeInterval time = [value floatValue];
		NSUInteger minutes = time / 60;
		NSUInteger seconds = (NSUInteger)time % 60;
#if __LP64__
		return [NSString stringWithFormat:@"%.2ld:%.2ld", minutes, seconds];
#else
		return [NSString stringWithFormat:@"%.2i:%.2i", minutes, seconds];
#endif
	} else {
		return nil;
	}
}


@end
