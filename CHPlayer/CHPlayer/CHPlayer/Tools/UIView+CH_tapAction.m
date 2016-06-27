//
//  UIView+CH_tapAction.m
//  CHPlayer
//
//  Created by Cher on 16/6/14.
//  Copyright © 2016年 Hxc. All rights reserved.
//

#import "UIView+CH_tapAction.h"

@implementation UIView (CH_tapAction)

//单击事件
- (void)addTapCallBack:(id)target sel:(SEL)selector
{
     self.userInteractionEnabled = YES;
     UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
     [self addGestureRecognizer:tap];
}

//双击事件
- (void)addDoubleTapCallBack:(id)target sel:(SEL)selector{
     
     self.userInteractionEnabled = YES;
     UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
     tap.numberOfTapsRequired = 2;
     [self addGestureRecognizer:tap];
}

@end
