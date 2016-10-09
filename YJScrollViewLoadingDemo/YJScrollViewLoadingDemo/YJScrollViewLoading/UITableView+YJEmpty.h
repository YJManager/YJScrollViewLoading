//
//  UITableView+YJEmpty.h
//  YJPalmNews
//
//  Created by YJHou on 14/8/13.
//  Copyright © 2014年 YJBSH. All rights reserved.
//  TableView的Loading相关设置

#import <UIKit/UIKit.h>
#import "UIScrollView+YJEmpty.h"

typedef void (^didTapActionBlock)();

@interface UITableView (YJEmpty) <YJEmptyDataSource, YJEmptyDelegate>

/** YES is install YJLoading */
@property (nonatomic, assign) BOOL installYJLoading;
/** custom Image */
@property (nonatomic, copy) NSString * loadedImageName;
/** nodata Title */
@property (nonatomic, copy) NSString * titleForNoDataView;


@property (nonatomic, copy) NSString * descriptionText;
@property (nonatomic, copy)NSString *buttonText;          /**< 刷新按钮文字 */
@property (nonatomic, strong) UIColor *buttonNormalColor;  /**< 按钮Normal状态下文字颜色 */
@property (nonatomic, strong) UIColor *buttonHighlightColor; /**<  按钮Highlight状态下文字颜色 */
@property (nonatomic, assign)CGFloat dataVerticalOffset;    /**< tableView中心点为基准点,(基准点＝0) */

/** 回调 */
@property(nonatomic, copy) didTapActionBlock tapBlock;


- (void)loadingWithTapBlock:(didTapActionBlock)block;

@end
