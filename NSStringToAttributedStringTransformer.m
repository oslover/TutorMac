//
//  NSStringToAttributedStringTransformer.m
//  Tutor for OS X Mountain Lion
//
//  Created by oDesk on 10/8/12.
//  Copyright (c) 2012 Noteboom. All rights reserved.
//

#import "NSStringToAttributedStringTransformer.h"

@implementation NSStringToAttributedStringTransformer

+(BOOL)allowsReverseTransformation
{
    return YES;
}
- (id)transformedValue:(id)value
{
    return (value == nil) ? nil : [[[NSAttributedString alloc] initWithString:value] autorelease];
}

- (id)reverseTransformedValue:(id)value
{
    return (value == nil) ? nil : [[(NSAttributedString *)value string] copy];
}

@end
