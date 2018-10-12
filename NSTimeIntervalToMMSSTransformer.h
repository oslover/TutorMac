//
//  NSTimeIntervalToMMSSTransformer.h
//  Tutor
//

#import <Cocoa/Cocoa.h>


@interface NSTimeIntervalToMMSSTransformer : NSValueTransformer

+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;
- (id)transformedValue:(id)value;

@end
