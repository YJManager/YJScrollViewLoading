//
//  UIView+YJEmptyLayout.h
//  YJPalmNews
//
//  Created by YJHou on 16/10/8.
//  Copyright © 2016年 YJBSH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (YJEmptyLayout)

//! 相等布局
- (NSLayoutConstraint *)equallyRelatedConstraintWithView:(UIView *)view attribute:(NSLayoutAttribute)attribute;

@end
