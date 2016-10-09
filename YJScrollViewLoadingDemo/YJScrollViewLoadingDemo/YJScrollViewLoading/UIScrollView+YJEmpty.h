//
//  UIScrollView+YJEmpty.h
//  YJPalmNews
//
//  Created by YJHou on 14/8/13.
//  Copyright © 2014年 YJBSH. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 数据源 */
@protocol YJEmptyDataSource <NSObject>

@optional
/** Image */
- (UIImage *)emptyViewImageInView:(UIScrollView *)scrollView;

/** imageTintColor */
- (UIColor *)emptyViewImageTintColorInView:(UIScrollView *)scrollView;

/** imageAnimation */
- (CAAnimation *)emptyViewImageAnimationInView:(UIScrollView *) scrollView;

/** title */
- (NSAttributedString *)emptyViewTitleInView:(UIScrollView *)scrollView;

/** detail */
- (NSAttributedString *)emptyViewDetailInView:(UIScrollView *)scrollView;

/** buttonTitle */
- (NSAttributedString *)emptyViewButtonTitleInView:(UIScrollView *)scrollView forState:(UIControlState)state;

/** buttonImage  */
- (UIImage *)emptyViewButtonImageInView:(UIScrollView *)scrollView forState:(UIControlState)state;

/** buttonBackgroundImage */
- (UIImage *)emptyViewButtonBackgroundImageInView:(UIScrollView *)scrollView forState:(UIControlState)state;

/** backgroundColor Default is ClearColor */
- (UIColor *)emptyViewBackgroundColorInView:(UIScrollView *)scrollView;

/** customView  Default is nil. Returning a custom view will ignore -emptyViewSpaceHeightInView configurations. */
- (UIView *)emptyViewWithCustomViewInView:(UIScrollView *)scrollView;

/** 竖直上的偏移量 Default is CGPointZero. */
- (CGFloat)emptyViewVerticalOffsetInView:(UIScrollView *)scrollView;

/** vertical space Default is 11 pts. */
- (CGFloat)emptyViewSpaceHeightInView:(UIScrollView *)scrollView;

@end


/** 代理 */
@protocol YJEmptyDelegate <NSObject>

@optional
/** 当渲染视图时 通知设置消失 Default is YES. */
- (BOOL)emptyViewShouldFadeInInView:(UIScrollView *)scrollView;

/** 视图将要渲染和显示 Default is YES. */
- (BOOL)emptyViewShouldDisplayInView:(UIScrollView *)scrollView;

/** 是否可以点击 Default is YES. */
- (BOOL)emptyViewShouldAllowTouchInView:(UIScrollView *)scrollView;

/** 是否允许滚动 Default is NO. */
- (BOOL)emptyViewShouldAllowScrollInView:(UIScrollView *)scrollView;

/** imageView 是否允许动画 Default is NO. */
- (BOOL)emptyViewShouldAnimateImageViewInView:(UIScrollView *)scrollView;

/** 点击视图 */
- (void)emptyViewInView:(UIScrollView *)scrollView didClickView:(UIView *)view;

/** 点击Btn */
- (void)emptyViewInView:(UIScrollView *)scrollView didClickButton:(UIButton *)button;

/** 无数据视图的生命周期 */
- (void)emptyViewWillAppearInView:(UIScrollView *)scrollView;
- (void)emptyViewDidAppearInView:(UIScrollView *)scrollView;
- (void)emptyViewWillDisappearInView:(UIScrollView *)scrollView;
- (void)emptyViewDidDisappearInView:(UIScrollView *)scrollView;

@end

@interface UIScrollView (YJEmpty)

@property (nonatomic, weak) IBOutlet id<YJEmptyDataSource> emptyDataSource;
@property (nonatomic, weak) IBOutlet id<YJEmptyDelegate>   emptyDelegate;
@property (nonatomic, readonly, getter=isEmptyViewVisible) BOOL emptyViewVisible;

/** 刷新YJEmptyView */
- (void)reloadEmptyView;
@end

