//
//  NSString+CH_stringWidthAndHeight.h
//  CHPlayer
//
//  Created by Cher on 16/6/14.
//  Copyright © 2016年 Hxc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (CH_stringWidthAndHeight)

/**
 *  获取字符串高度
 *
 *  @param attribute 字符串的属性 attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:12.f]}
 *  @param width     字符串设定的宽度
 *
 *  @return 字符串高度
 */
- (CGFloat)heightWithStringAttribute:(NSDictionary <NSString *, id> *)attribute fixedWidth:(CGFloat)width;

/**
 *  获取字符串宽度
 *
 *  @param attribute 字符串的属性 attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:12.f]}
 *
 *  @return 字符串宽度
 */
- (CGFloat)widthWithStringAttribute:(NSDictionary <NSString *, id> *)attribute;


@end
