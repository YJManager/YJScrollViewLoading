//
//  UIView+YJEmptyLayout.m
//  YJPalmNews
//
//  Created by YJHou on 16/10/8.
//  Copyright © 2016年 YJBSH. All rights reserved.
//

#import "UIView+YJEmptyLayout.h"

@implementation UIView (YJEmptyLayout)

- (NSLayoutConstraint *)equallyRelatedConstraintWithView:(UIView *)view attribute:(NSLayoutAttribute)attribute{
    return [NSLayoutConstraint constraintWithItem:view attribute:attribute relatedBy:NSLayoutRelationEqual toItem:self attribute:attribute multiplier:1.0 constant:0.0];
}

@end
