//
//  YJEmptyDataView.h
//  YJPalmNews
//
//  Created by YJHou on 16/10/8.
//  Copyright © 2016年 YJBSH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YJEmptyDataView : UIView

@property (nonatomic, readonly) UIView      * contentView;
@property (nonatomic, strong)   UIView      * customView;

@property (nonatomic, readonly) UIImageView * imageView;
@property (nonatomic, readonly) UILabel     * titleLabel;
@property (nonatomic, readonly) UILabel     * detailLabel;
@property (nonatomic, readonly) UIButton    * button;

@property (nonatomic, assign) CGFloat verticalOffset;
@property (nonatomic, assign) CGFloat verticalSpace;

@property (nonatomic, assign) BOOL fadeInOnDisplay;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

- (void)_setupConstraints;
- (void)prepareForReuse;


@end
