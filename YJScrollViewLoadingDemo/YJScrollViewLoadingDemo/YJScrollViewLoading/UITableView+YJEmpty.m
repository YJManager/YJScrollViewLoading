//
//  UITableView+YJEmpty.m
//  YJPalmNews
//
//  Created by YJHou on 14/1/13.
//  Copyright © 2014年 YJManager. All rights reserved.
//

#import "UITableView+YJEmpty.h"
#import <objc/runtime.h>

static char const * const kInstallYJLoadingKey      =  "kInstallYJLoadingKey";
static char const * const kLoadedImgNameKey         =  "kLoadedImgNameKey";
static char const * const kTitleForNoDataViewKey    =  "kTitleForNoDataViewKey";
static char const * const kDetailForNoDataView      =  "kDetailForNoDataView";
static char const * const kButtonTitleKey           =  "kButtonTitleKey";
static char const * const kButtonNormalColorKey     =  "kButtonNormalColorKey";
static char const * const kButtonHighlightColorKey  =  "kButtonHighlightColorKey";
static char const * const kVOffsetForNoDataViewKey  =  "kVOffsetForNoDataViewKey";
static char const * const kreloadClickBlockKey      =  "kreloadClickBlockKey";

@interface UITableView ()
@property(nonatomic, copy) reloadClickActionBlock tapBlock;
@end

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

#pragma mark - Setter & Getter
// 1.>>>>>>> install <<<<<<<<<<
- (void)setInstallYJLoading:(BOOL)installYJLoading{
    if (self.installYJLoading == installYJLoading) return;
    
    objc_setAssociatedObject(self, kInstallYJLoadingKey, @(installYJLoading), OBJC_ASSOCIATION_ASSIGN);
    
    self.emptyDataSource = self;
    self.emptyDelegate = self;
    [self reloadEmptyView];
}
- (BOOL)installYJLoading{
    return [objc_getAssociatedObject(self, kInstallYJLoadingKey) boolValue];
}

// 2.>>>>>>> loadedImage <<<<<<<<<<<
-(void)setLoadedImageName:(NSString *)loadedImageName{
    objc_setAssociatedObject(self, kLoadedImgNameKey, loadedImageName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(NSString *)loadedImageName{
    return objc_getAssociatedObject(self, kLoadedImgNameKey);
}

// 3.>>>>>>>> titleForNoDataView <<<<<<<
- (void)setTitleForNoDataView:(NSString *)titleForNoDataView{
    objc_setAssociatedObject(self, kTitleForNoDataViewKey, titleForNoDataView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)titleForNoDataView{
    return objc_getAssociatedObject(self, kTitleForNoDataViewKey);
}

// 4.>>>>>> kDetailForNoDataView <<<<<<
- (void)setDetailForNoDataView:(NSString *)detailForNoDataView{
    objc_setAssociatedObject(self, kDetailForNoDataView, detailForNoDataView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)detailForNoDataView{
    return objc_getAssociatedObject(self, kDetailForNoDataView);
}

// 5. >>>>>> kButtonTitleKey <<<<<
- (void)setButtonTitle:(NSString *)buttonTitle{
    objc_setAssociatedObject(self, kButtonTitleKey, buttonTitle, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)buttonTitle{
    return objc_getAssociatedObject(self, kButtonTitleKey);
}

// 6.>>>>>> kButtonNormalColorKey <<<<<<

-(void)setButtonNormalColor:(UIColor *)buttonNormalColor{
    objc_setAssociatedObject(self, kButtonNormalColorKey, buttonNormalColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(UIColor *)buttonNormalColor{
    return objc_getAssociatedObject(self, kButtonNormalColorKey);
}

// 7.>>>>>>>>> kButtonHighlightColorKey <<<<<
-(void)setButtonHighlightColor:(UIColor *)buttonHighlightColor{
    objc_setAssociatedObject(self, kButtonHighlightColorKey, buttonHighlightColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(UIColor *)buttonHighlightColor{
    return objc_getAssociatedObject(self, kButtonHighlightColorKey);
}

// 8.>>>>>>>>> kVOffsetForNoDataViewKey <<<<<
- (void)setVerticalOffsetForNoDataView:(CGFloat)verticalOffsetForNoDataView{
    objc_setAssociatedObject(self, kVOffsetForNoDataViewKey, @(verticalOffsetForNoDataView),OBJC_ASSOCIATION_RETAIN);
}
- (CGFloat)verticalOffsetForNoDataView{
    return [objc_getAssociatedObject(self, kVOffsetForNoDataViewKey) floatValue];
}

// 9.>>>>>>>>> kreloadClickBlockKey <<<<<
- (void)setTapBlock:(reloadClickActionBlock)tapBlock{
    objc_setAssociatedObject(self, kreloadClickBlockKey, tapBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (reloadClickActionBlock)tapBlock{
    return objc_getAssociatedObject(self, kreloadClickBlockKey);
}

#pragma mark - Public API
- (void)loadingWithTapBlock:(reloadClickActionBlock)block{
    if (self.tapBlock) {
        block = self.tapBlock;
    }
    self.tapBlock = block;
}


#pragma mark - YJEmptyDataSetSource
- (UIView *)emptyViewWithCustomViewInView:(UIScrollView *)scrollView{
    if (self.installYJLoading) {
        
        UIView * emptyView = [[UIView alloc] initWithFrame:scrollView.bounds];
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityView startAnimating];
        activityView.center = emptyView.center;
        [emptyView addSubview:activityView];
        
        UILabel * loading = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 15)];
        loading.textAlignment = NSTextAlignmentCenter;
        loading.text = @"加载中...";
        loading.textColor = [UIColor lightGrayColor];
        loading.font = [UIFont systemFontOfSize:11.0f];
        
        CGPoint center = emptyView.center;
        center.y += 25;
        loading.center = center;
        [emptyView addSubview:loading];
        
        return emptyView;
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
        if (self.titleForNoDataView) {
            text = self.titleForNoDataView;
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

- (NSAttributedString *)emptyViewDetailInView:(UIScrollView *)scrollView{
    if (self.installYJLoading) {
        return nil;
    }else {
        NSString *text = @"没有数据！您可以尝试重新获取";
        if (self.detailForNoDataView) {
            text = self.detailForNoDataView;
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
        
        return [[NSAttributedString alloc] initWithString:self.buttonTitle ? self.buttonTitle : @"再次刷新" attributes:attributes];
    }
}

- (CGFloat)emptyViewVerticalOffsetInView:(UIScrollView *)scrollView{
    if (self.verticalOffsetForNoDataView != 0) {
        return self.verticalOffsetForNoDataView;
    }
    return 0.0;
}
#pragma mark - YJEmptyDataSetDelegate Methods
// 返回是否显示空状态的所有组件，默认:YES
-(BOOL)emptyViewShouldDisplayInView:(UIScrollView *)scrollView{
    return YES;
}

- (BOOL)emptyViewIsAllowTouchInView:(UIScrollView *)scrollView{
    return !self.installYJLoading;
}

- (BOOL)emptyViewIsAllowScrollInView:(UIScrollView *)scrollView{
    return NO;
}

- (BOOL)emptyViewIsAllowAnimateImageViewInView:(UIScrollView *)scrollView{
    return YES;
}

- (void)emptyViewInView:(UIScrollView *)scrollView didClickButton:(UIButton *)button{
    if (self.tapBlock) {
        self.tapBlock();
        [self reloadEmptyView];
    }
}

+ (void)load{
    [self exchangeOriginalSelector:@selector(reloadData) newSelector:@selector(reloadDataYJLoading) isClassMethod:NO];
}

+ (void)exchangeOriginalSelector:(SEL)originalSelector newSelector:(SEL)newSelector isClassMethod:(BOOL)isClassMethod{
    
    Class cls = [self class];
    Method originalMethod;
    Method swizzledMethod;
    
    if (isClassMethod) {
        originalMethod = class_getClassMethod(cls, originalSelector);
        swizzledMethod = class_getClassMethod(cls, newSelector);
    } else {
        originalMethod = class_getInstanceMethod(cls, originalSelector);
        swizzledMethod = class_getInstanceMethod(cls, newSelector);
    }
    
    if (!originalMethod) {
        return;
    }
    method_exchangeImplementations(originalMethod, swizzledMethod);
}


- (void)reloadDataYJLoading{
    
    NSInteger items = 0;
    id <UITableViewDataSource> dataSource = self.dataSource;

    NSInteger sections = 1;

    if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        sections = [dataSource numberOfSectionsInTableView:self];
    }

    if (dataSource && [dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
        for (NSInteger section = 0; section < sections; section++) {
            items += [dataSource tableView:self numberOfRowsInSection:section];
        }
    }

    if (items == 0) {
        self.installYJLoading = NO;
    }
    
    [self reloadDataYJLoading];
}


@end
