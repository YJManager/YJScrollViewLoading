//
//  UITableView+YJEmpty.h
//  YJPalmNews
//
//  Created by YJHou on 14/1/13.
//  Copyright © 2014年 YJManager. All rights reserved.
//  TableView的Loading相关设置

#import <UIKit/UIKit.h>
#import "UIScrollView+YJEmpty.h"

typedef void (^reloadClickActionBlock)();

@interface UITableView (YJEmpty) <YJEmptyDataSource, YJEmptyDelegate>

/** YES is install YJLoading */
@property (nonatomic, assign) BOOL installYJLoading;
/** custom Image */
@property (nonatomic, copy) NSString * loadedImageName;
/** nodata Title */
@property (nonatomic, copy) NSString * titleForNoDataView;
/** detailForNoDataView */
@property (nonatomic, copy) NSString * detailForNoDataView;
/** button title */
@property (nonatomic, copy) NSString * buttonTitle;
/** buttonNormalColor */
@property (nonatomic, strong) UIColor * buttonNormalColor;
/** buttonHighlightColor */
@property (nonatomic, strong) UIColor * buttonHighlightColor;
/** tableView Center Offset */
@property (nonatomic, assign) CGFloat verticalOffsetForNoDataView;

- (void)loadingWithClickBlock:(reloadClickActionBlock)block;

@end
