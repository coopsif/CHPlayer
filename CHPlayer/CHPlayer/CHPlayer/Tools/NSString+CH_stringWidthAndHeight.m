//
//  NSString+CH_stringWidthAndHeight.m
//  CHPlayer
//
//  Created by Cher on 16/6/14.
//  Copyright © 2016年 Hxc. All rights reserved.
//

#import "NSString+CH_stringWidthAndHeight.h"

@implementation NSString (CH_stringWidthAndHeight)

- (CGFloat)heightWithStringAttribute:(NSDictionary <NSString *, id> *)attribute fixedWidth:(CGFloat)width {
     
     NSParameterAssert(attribute);
     CGFloat height = 0;
     if (self.length) {
          
          CGRect rect = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                           options:NSStringDrawingTruncatesLastVisibleLine |NSStringDrawingUsesLineFragmentOrigin |
                         NSStringDrawingUsesFontLeading
                                        attributes:attribute
                                           context:nil];
          height = rect.size.height;
     }
     
     return height;
}

- (CGFloat)widthWithStringAttribute:(NSDictionary <NSString *, id> *)attribute {
     
     NSParameterAssert(attribute);
     CGFloat width = 0;
     if (self.length) {
          CGRect rect = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, 0)
                                           options:NSStringDrawingTruncatesLastVisibleLine |NSStringDrawingUsesLineFragmentOrigin |
                         NSStringDrawingUsesFontLeading
                                        attributes:attribute
                                           context:nil];
          return rect.size.width;
     }
     return width;
}

@end
