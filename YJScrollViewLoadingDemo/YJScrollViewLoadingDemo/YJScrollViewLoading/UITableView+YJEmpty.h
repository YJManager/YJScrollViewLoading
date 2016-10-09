//
//  UITableView+YJEmpty.h
//  YJPalmNews
//
//  Created by YJHou on 14/8/13.
//  Copyright © 2014年 YJBSH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+YJEmpty.h"


typedef void (^didTapActionBlock)();

@interface UITableView (YJEmpty) <YJEmptyDataSource, YJEmptyDelegate>

@property (nonatomic, assign) BOOL loading;

@property (nonatomic, copy)NSString * loadedImageName;    /**< 空状态下显示图片 */
@property (nonatomic, copy)NSString *descriptionText;     /**< 空状态下的文字详情 */
@property (nonatomic, copy)NSString *buttonText;          /**< 刷新按钮文字 */
@property (nonatomic, strong) UIColor *buttonNormalColor;  /**< 按钮Normal状态下文字颜色 */
@property (nonatomic, strong) UIColor *buttonHighlightColor; /**<  按钮Highlight状态下文字颜色 */
@property (nonatomic, assign)CGFloat dataVerticalOffset;    /**< tableView中心点为基准点,(基准点＝0) */

/** 回调 */
@property(nonatomic, copy) didTapActionBlock tapBlock;


- (void)loadingWithTapBlock:(didTapActionBlock)block;

@end
