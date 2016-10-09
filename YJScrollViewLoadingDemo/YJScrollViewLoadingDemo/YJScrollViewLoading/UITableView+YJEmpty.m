//
//  UITableView+YJEmpty.m
//  YJPalmNews
//
//  Created by YJHou on 14/8/13.
//  Copyright © 2014年 YJBSH. All rights reserved.
//

#import "UITableView+YJEmpty.h"
#import <objc/runtime.h>

static char const * const kLoadingKey               =  "kLoadingKey";
static char const * const kLoadedImgNameKey         =  "kLoadedImgNameKey";
static char const * const kDescriptionTextKey       =  "kDescriptionTextKey";
static char const * const kButtonTextKey            =  "kButtonTextKey";
static char const * const kButtonNormalColorKey     =  "kButtonNormalColorKey";
static char const * const kButtonHighlightColorKey  =  "kButtonHighlightColorKey";
static char const * const kDataVerticalOffsetKey    =  "kDataVerticalOffsetKey";
static char const * const kTapBlockKey              =  "kTapBlockKey";

@implementation UITableView (YJEmpty)

//+ (void)load{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        SEL systemSel = @selector(initWithFrame:style:);
//        SEL swizzSel = @selector(swiz_init);
//        Method systemMethod = class_getInstanceMethod([self class], systemSel);
//        Method swizzMethod = class_getInstanceMethod([self class], swizzSel);
//
//        BOOL isAdd = class_addMethod(self, systemSel, method_getImplementation(swizzMethod), method_getTypeEncoding(swizzMethod));
//        if (isAdd) {
//            class_replaceMethod(self, swizzSel, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
//        }else{
//            method_exchangeImplementations(systemMethod, swizzMethod);
//        }
//    });
//}

//- (void)swiz_init{
//     NSLog(@"swizzle");
//    [self swiz_init];
//}

#pragma mark - Setter
- (void)setInstallYJLoading:(BOOL)installYJLoading{
    if (self.installYJLoading == installYJLoading) return;
    
    objc_setAssociatedObject(self, kLoadingKey, @(installYJLoading), OBJC_ASSOCIATION_ASSIGN);
    
    self.emptyDataSource = self;
    self.emptyDelegate = self;
    [self reloadEmptyView];
}

- (void)setTapBlock:(didTapActionBlock)tapBlock{
    objc_setAssociatedObject(self, kTapBlockKey, tapBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(void)setLoadedImageName:(NSString *)loadedImageName{
    objc_setAssociatedObject(self, kLoadedImgNameKey, loadedImageName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(void)setDataVerticalOffset:(CGFloat)dataVerticalOffset{
    objc_setAssociatedObject(self, kDataVerticalOffsetKey,@(dataVerticalOffset),OBJC_ASSOCIATION_RETAIN);// 如果是对象，请用RETAIN。坑
}
-(void)setDescriptionText:(NSString *)descriptionText{
    objc_setAssociatedObject(self, kDescriptionTextKey, descriptionText, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(void)setButtonText:(NSString *)buttonText{
    objc_setAssociatedObject(self, kButtonTextKey, buttonText, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(void)setButtonNormalColor:(UIColor *)buttonNormalColor{
    objc_setAssociatedObject(self, kButtonNormalColorKey, buttonNormalColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(void)setButtonHighlightColor:(UIColor *)buttonHighlightColor{
    objc_setAssociatedObject(self, kButtonHighlightColorKey, buttonHighlightColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)loadingWithTapBlock:(didTapActionBlock)block{
    if (self.tapBlock) {
        block = self.tapBlock;
    }
    self.tapBlock = block;
}

#pragma mark - Getter
- (BOOL)installYJLoading{
    return [objc_getAssociatedObject(self, kLoadingKey) boolValue];

}

- (didTapActionBlock)tapBlock{
    return objc_getAssociatedObject(self, kTapBlockKey);
}

-(NSString *)loadedImageName{
    return objc_getAssociatedObject(self, kLoadedImgNameKey);
}
-(CGFloat)dataVerticalOffset{
    return [objc_getAssociatedObject(self, kDataVerticalOffsetKey) floatValue];
}
-(NSString *)descriptionText{
    return objc_getAssociatedObject(self, kDescriptionTextKey);
}
-(NSString *)buttonText{
    return objc_getAssociatedObject(self, kButtonTextKey);
}
-(UIColor *)buttonNormalColor{
    return objc_getAssociatedObject(self, kButtonNormalColorKey);
}
-(UIColor *)buttonHighlightColor{
    return objc_getAssociatedObject(self, kButtonHighlightColorKey);
}

#pragma mark - YJEmptyDataSetSource
- (UIView *)emptyViewWithCustomViewInView:(UIScrollView *)scrollView{
    if (self.installYJLoading) {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityView startAnimating];
        return activityView;
    }else {
        return nil;
    }
}

- (UIImage *)emptyViewImageInView:(UIScrollView *)scrollView{
    if (self.installYJLoading) {
        return nil;
    }else {
        NSString *imageName = @"noDataDefault.png";
        if (self.loadedImageName) {
            imageName = self.loadedImageName;
        }
        return [UIImage imageNamed:imageName];
    }
}

- (NSAttributedString *)emptyViewTitleInView:(UIScrollView *)scrollView{
    if (self.installYJLoading) {
        return nil;
    }else {
        
        NSString *text = @"没有数据";
        
        NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        paragraph.alignment = NSTextAlignmentCenter;
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                     NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                     NSParagraphStyleAttributeName: paragraph};
        
        return [[NSAttributedString alloc] initWithString:text attributes:attributes];
    }
}

- (NSAttributedString *)emptyViewDetailInView:(UIScrollView *)scrollView{
    if (self.installYJLoading) {
        return nil;
    }else {
        NSString *text = @"没有数据！您可以尝试重新获取";
        if (self.descriptionText) {
            text = self.descriptionText;
        }
        NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        paragraph.alignment = NSTextAlignmentCenter;
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                     NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                     NSParagraphStyleAttributeName: paragraph};
        
        return [[NSAttributedString alloc] initWithString:text attributes:attributes];
    }
}

- (NSAttributedString *)emptyViewButtonTitleInView:(UIScrollView *)scrollView forState:(UIControlState)state{
    if (self.installYJLoading) {
        return nil;
    }else {
        UIColor *textColor = nil;
        // 某种状态下的颜色
        UIColor *colorOne = [UIColor colorWithRed:253/255.0f green:120/255.0f blue:76/255.0f alpha:1];
        UIColor *colorTow = [UIColor colorWithRed:247/255.0f green:188/255.0f blue:169/255.0f alpha:1];
        // 判断外部是否有设置
        colorOne = self.buttonNormalColor ? self.buttonNormalColor : colorOne;
        colorTow = self.buttonHighlightColor ? self.buttonHighlightColor : colorTow;
        textColor = state == UIControlStateNormal ? colorOne : colorTow;
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:16.0f],
                                     NSForegroundColorAttributeName: textColor};
        
        return [[NSAttributedString alloc] initWithString:self.buttonText ? self.buttonText : @"再次刷新" attributes:attributes];
    }
}

- (CGFloat)emptyViewVerticalOffsetInView:(UIScrollView *)scrollView{
    if (self.dataVerticalOffset != 0) {
        return self.dataVerticalOffset;
    }
    return 0.0;
}
#pragma mark - YJEmptyDataSetDelegate Methods
// 返回是否显示空状态的所有组件，默认:YES
-(BOOL)emptyViewShouldDisplayInView:(UIScrollView *)scrollView{
    return YES;
}
- (BOOL)emptyViewShouldAllowTouchInView:(UIScrollView *)scrollView{
    // 只有非加载状态能交互
    return !self.installYJLoading;
}
- (BOOL)emptyViewShouldAllowScrollInView:(UIScrollView *)scrollView{
    return NO;
}
- (BOOL)emptyViewShouldAnimateImageViewInView:(UIScrollView *)scrollView{
    return YES;
}

- (void)emptyViewInView:(UIScrollView *)scrollView didClickView:(UIView *)view{
    NSLog(@"Click-View");
}

- (void)emptyViewInView:(UIScrollView *)scrollView didClickButton:(UIButton *)button{
    if (self.tapBlock) {
        self.tapBlock();
        [self reloadEmptyView];
    }
    NSLog(@"Click-Btn");
}


@end
