//
//  UIScrollView+YJEmpty.m
//  YJPalmNews
//
//  Created by YJHou on 14/8/13.
//  Copyright © 2014年 YJBSH. All rights reserved.
//

#import "UIScrollView+YJEmpty.h"
#import <objc/runtime.h>
#import "YJEmptyDataView.h"

static char const * const kEmptyDataSource =     "emptyDataSource";
static char const * const kEmptyDelegate   =     "emptyDelegate";
static char const * const kEmptyDataView   =     "emptyDataView";
#define kEmptyImageViewAnimationKey @"com.ismonkey.emptyData.imageViewAnimation"

@interface UIScrollView () <UIGestureRecognizerDelegate>

@property (nonatomic, readonly) YJEmptyDataView *emptyDataView;

@end

@implementation UIScrollView (YJEmpty)

#pragma mark - Setter (Public)
- (void)setEmptyDataSource:(id<YJEmptyDataSource>)emptyDataSource{
    if (emptyDataSource == nil || ![self _canDisplay]) {
        [self _invalidate];
    }
    objc_setAssociatedObject(self, kEmptyDataSource, emptyDataSource, OBJC_ASSOCIATION_ASSIGN);
    [self swizzleIfPossible:@selector(reloadData)];
    if ([self isKindOfClass:[UITableView class]]) {
        [self swizzleIfPossible:@selector(endUpdates)];
    }
}

- (void)setEmptyDelegate:(id<YJEmptyDelegate>)emptyDelegate{
    if (emptyDelegate == nil) {
        [self _invalidate];
    }
    objc_setAssociatedObject(self, kEmptyDelegate, emptyDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (void)setEmptyDataView:(YJEmptyDataView *)emptyDataView{
    objc_setAssociatedObject(self, kEmptyDataView, emptyDataView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Getters (Private)
- (id<YJEmptyDataSource>)emptyDataSource{
    return objc_getAssociatedObject(self, kEmptyDataSource);
}

- (id<YJEmptyDelegate>)emptyDelegate{
    return objc_getAssociatedObject(self, kEmptyDelegate);
}

- (BOOL)isEmptyViewVisible{
    YJEmptyDataView * view = objc_getAssociatedObject(self, kEmptyDataView);
    return view?!view.hidden:NO;
}

- (YJEmptyDataView *)emptyDataView{
    
    YJEmptyDataView *view = objc_getAssociatedObject(self, kEmptyDataView);
    if (view == nil){
        view = [YJEmptyDataView new];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        view.hidden = YES;
        view.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapContentView:)];
        view.tapGesture.delegate = self;
        [view addGestureRecognizer:view.tapGesture];
        [self setEmptyDataView:view];
    }
    return view;
}

- (void)_invalidate{
    [self _willDisappear];
    if (self.emptyDataView) {
        [self.emptyDataView prepareForReuse];
        [self.emptyDataView removeFromSuperview];
        [self setEmptyDataView:nil];
    }
    self.scrollEnabled = YES;
    [self _didDisappear];
}


#pragma mark - Reload APIs (Private)
- (void)_reloadEmptyView{
    if (![self _canDisplay]) return;
    
    if ([self shouldDisplay] && [self _itemsCount] == 0){
        [self _willAppear];
        YJEmptyDataView *view = self.emptyDataView;
        if (!view.superview) {
            if (([self isKindOfClass:[UITableView class]] || [self isKindOfClass:[UICollectionView class]]) && self.subviews.count > 1) {
                [self insertSubview:view atIndex:0];
            }else {
                [self addSubview:view];
            }
        }
        
        [view prepareForReuse];
        
        UIView *customView = [self emptyCustomView];
        
        if (customView) {
            view.customView = customView;
        }else {
            NSAttributedString *titleLabelString = [self titleLabelString];
            NSAttributedString *detailLabelString = [self detailLabelString];
            
            UIImage *buttonImage = [self buttonImageForState:UIControlStateNormal];
            NSAttributedString *buttonTitle = [self buttonTitleForState:UIControlStateNormal];
            
            UIImage *image = [self topImage];
            UIColor *imageTintColor = [self imageTintColor];
            UIImageRenderingMode renderingMode = imageTintColor?UIImageRenderingModeAlwaysTemplate:UIImageRenderingModeAlwaysOriginal;
            
            view.verticalSpace = [self verticalSpace];
            
            if (image) {
                if ([image respondsToSelector:@selector(imageWithRenderingMode:)]) {
                    view.imageView.image = [image imageWithRenderingMode:renderingMode];
                    view.imageView.tintColor = imageTintColor;
                }else {
                    @throw [NSException exceptionWithName:@"YJEmpty Error" reason:@"Version is too low, Minimum support iOS 7" userInfo:nil];
                }
            }
            
            if (titleLabelString) {
                view.titleLabel.attributedText = titleLabelString;
            }
            
            if (detailLabelString) {
                view.detailLabel.attributedText = detailLabelString;
            }
            
            if (buttonImage) {
                [view.button setImage:buttonImage forState:UIControlStateNormal];
                [view.button setImage:[self buttonImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
            }else if (buttonTitle) {
                [view.button setAttributedTitle:buttonTitle forState:UIControlStateNormal];
                [view.button setAttributedTitle:[self buttonTitleForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
                [view.button setBackgroundImage:[self buttonBackgroundImageForState:UIControlStateNormal] forState:UIControlStateNormal];
                [view.button setBackgroundImage:[self buttonBackgroundImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
            }
        }
        
        view.verticalOffset = [self verticalOffset];
        view.backgroundColor = [self emptyBackgroundColor];
        view.hidden = NO;
        view.clipsToBounds = YES;
        view.userInteractionEnabled = [self isTouchAllowed];
        view.fadeInOnDisplay = [self shouldFadeIn];
        [view _setupConstraints];
        
        [UIView performWithoutAnimation:^{
            [view layoutIfNeeded];
        }];
        self.scrollEnabled = [self isScrollAllowed];
        
        if ([self isImageViewAnimateAllowed]){
            CAAnimation *animation = [self imageAnimation];
            if (animation) {
                [self.emptyDataView.imageView.layer addAnimation:animation forKey:kEmptyImageViewAnimationKey];
            }
        }else if ([self.emptyDataView.imageView.layer animationForKey:kEmptyImageViewAnimationKey]) {
            [self.emptyDataView.imageView.layer removeAnimationForKey:kEmptyImageViewAnimationKey];
        }
        
        [self _didAppear];
    }else if (self.isEmptyViewVisible) {
        [self _invalidate];
    }
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer.view isEqual:self.emptyDataView]) {
        return [self isTouchAllowed];
    }
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    UIGestureRecognizer * tapGesture = self.emptyDataView.tapGesture;
    if ([gestureRecognizer isEqual:tapGesture] || [otherGestureRecognizer isEqual:tapGesture]) {
        return YES;
    }
    
    if ( (self.emptyDelegate != (id)self) && [self.emptyDelegate respondsToSelector:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)]) {
        return [(id)self.emptyDelegate gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
    }
    return NO;
}

#pragma mark - Reload APIs (Public)
- (void)reloadEmptyView{
    [self _reloadEmptyView];
}

// >>>>>>>>>> Setting Support>>>>>>>>>>>>>>>>
- (BOOL)_canDisplay{
    if (self.emptyDataSource && [self.emptyDataSource conformsToProtocol:@protocol(YJEmptyDataSource)]) {
        // 备用支持UITableView、UICollectionView、UIScrollView类型
        if ([self isKindOfClass:[UITableView class]] || [self isKindOfClass:[UICollectionView class]] || [self isKindOfClass:[UIScrollView class]]) {
            return YES;
        }
    }
    return NO;
}

- (NSInteger)_itemsCount{
    
    NSInteger items = 0;
    if (![self respondsToSelector:@selector(dataSource)]) return items;
    
    if ([self isKindOfClass:[UITableView class]]) { // UITableView support
        
        UITableView * tableView = (UITableView *)self;
        id <UITableViewDataSource> dataSource = tableView.dataSource;
        
        NSInteger sections = 1;
        
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [dataSource numberOfSectionsInTableView:tableView];
        }
        
        if (dataSource && [dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
            for (NSInteger section = 0; section < sections; section++) {
                items += [dataSource tableView:tableView numberOfRowsInSection:section];
            }
        }
    }else if ([self isKindOfClass:[UICollectionView class]]) { // UICollectionView support
        
        UICollectionView *collectionView = (UICollectionView *)self;
        id <UICollectionViewDataSource> dataSource = collectionView.dataSource;
        
        NSInteger sections = 1;
        
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            sections = [dataSource numberOfSectionsInCollectionView:collectionView];
        }
        
        if (dataSource && [dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
            for (NSInteger section = 0; section < sections; section++) {
                items += [dataSource collectionView:collectionView numberOfItemsInSection:section];
            }
        }
    }
    return items;
}

// >>>>>>>>>>>> Method Swizzling >>>>>>>>>>>>>>>>
static NSMutableDictionary *_impLookupTable;
static NSString * const YJSwizzleInfoPointerKey = @"pointer";
static NSString * const YJSwizzleInfoOwnerKey = @"owner";
static NSString * const YJSwizzleInfoSelectorKey = @"selector";

void _original_implementation(id self, SEL _cmd){
    NSString * key = [self _getImplementationKeyWithTarget:self selector:_cmd];
    NSDictionary *swizzleInfo = [_impLookupTable objectForKey:key];
    NSValue *impValue = [swizzleInfo valueForKey:YJSwizzleInfoPointerKey];
    IMP impPointer = [impValue pointerValue];
    [self _reloadEmptyView];
    if (impPointer) {
        ((void(*)(id,SEL))impPointer)(self,_cmd);
    }
}

/** create key e.g. UITableView_reloadData */
- (NSString *)_getImplementationKeyWithTarget:(id)target selector:(SEL)selector{
    if (!target || !selector) return nil;
    
    Class baseClass;
    if ([target isKindOfClass:[UITableView class]]) baseClass = [UITableView class];
    else if ([target isKindOfClass:[UICollectionView class]]) baseClass = [UICollectionView class];
    else if ([target isKindOfClass:[UIScrollView class]]) baseClass = [UIScrollView class];
    else return nil;
    
    NSString * className = NSStringFromClass([baseClass class]);
    NSString * selectorName = NSStringFromSelector(selector);
    return [NSString stringWithFormat:@"%@_%@", className, selectorName];
}

- (void)swizzleIfPossible:(SEL)selector{
    if (![self respondsToSelector:selector]) return;
    
    if (_impLookupTable == nil) {
        _impLookupTable = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    
    for (NSDictionary *info in [_impLookupTable allValues]) {
        Class class = [info objectForKey:YJSwizzleInfoOwnerKey];
        NSString *selectorName = [info objectForKey:YJSwizzleInfoSelectorKey];
        
        if ([selectorName isEqualToString:NSStringFromSelector(selector)]) {
            if ([self isKindOfClass:class]) {
                return;
            }
        }
    }
    
    NSString * key = [self _getImplementationKeyWithTarget:self selector:selector];
    NSValue * impValue = [[_impLookupTable objectForKey:key] valueForKey:YJSwizzleInfoPointerKey];
    
    if (impValue || !key) {
        return;
    }
    
    Method method = class_getInstanceMethod([self class], selector);
    IMP yj_newImplementation = method_setImplementation(method, (IMP)_original_implementation);
    
    NSDictionary *swizzledInfo = @{YJSwizzleInfoOwnerKey:[self class], YJSwizzleInfoSelectorKey:NSStringFromSelector(selector), YJSwizzleInfoPointerKey:[NSValue valueWithPointer:yj_newImplementation]};
    
    [_impLookupTable setObject:swizzledInfo forKey:key];
}


// >>>>>>>>> DataSource >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#pragma mark - DataSource Getters (Private)
- (UIImage *)topImage{
    if (self.emptyDataSource && [self.emptyDataSource respondsToSelector:@selector(emptyViewImageInView:)]) {
        UIImage *image = [self.emptyDataSource emptyViewImageInView:self];
        if (image) NSAssert([image isKindOfClass:[UIImage class]], @"You must return a valid UIImage object for -emptyViewImageInView:");
        return image;
    }
    return nil;
}

- (UIColor *)imageTintColor{
    if (self.emptyDataSource && [self.emptyDataSource respondsToSelector:@selector(emptyViewImageTintColorInView:)]) {
        UIColor *color = [self.emptyDataSource emptyViewImageTintColorInView:self];
        if (color) NSAssert([color isKindOfClass:[UIColor class]], @"You must return a valid UIColor object for -emptyViewImageTintColorInView:");
        return color;
    }
    return nil;
}

- (CAAnimation *)imageAnimation{
    if (self.emptyDataSource && [self.emptyDataSource respondsToSelector:@selector(emptyViewImageAnimationInView:)]) {
        CAAnimation *imageAnimation = [self.emptyDataSource emptyViewImageAnimationInView:self];
        if (imageAnimation) NSAssert([imageAnimation isKindOfClass:[CAAnimation class]], @"You must return a valid CAAnimation object for -emptyViewImageAnimationInView:");
        return imageAnimation;
    }
    return nil;
}

- (NSAttributedString *)titleLabelString{
    if (self.emptyDataSource && [self.emptyDataSource respondsToSelector:@selector(emptyViewTitleInView:)]) {
        NSAttributedString *string = [self.emptyDataSource emptyViewTitleInView:self];
        if (string) NSAssert([string isKindOfClass:[NSAttributedString class]], @"You must return a valid NSAttributedString object for -emptyViewTitleInView:");
        return string;
    }
    return nil;
}

- (NSAttributedString *)detailLabelString{
    if (self.emptyDataSource && [self.emptyDataSource respondsToSelector:@selector(emptyViewDetailInView:)]) {
        NSAttributedString *string = [self.emptyDataSource emptyViewDetailInView:self];
        if (string) NSAssert([string isKindOfClass:[NSAttributedString class]], @"You must return a valid NSAttributedString object for -emptyViewDetailInView:");
        return string;
    }
    return nil;
}

- (NSAttributedString *)buttonTitleForState:(UIControlState)state{
    if (self.emptyDataSource && [self.emptyDataSource respondsToSelector:@selector(emptyViewButtonTitleInView:forState:)]) {
        NSAttributedString *string = [self.emptyDataSource emptyViewButtonTitleInView:self forState:state];
        if (string) NSAssert([string isKindOfClass:[NSAttributedString class]], @"You must return a valid NSAttributedString object for -emptyViewButtonTitleInView:forState:");
        return string;
    }
    return nil;
}

- (UIImage *)buttonImageForState:(UIControlState)state{
    if (self.emptyDataSource && [self.emptyDataSource respondsToSelector:@selector(emptyViewButtonImageInView:forState:)]) {
        UIImage *image = [self.emptyDataSource emptyViewButtonImageInView:self forState:state];
        if (image) NSAssert([image isKindOfClass:[UIImage class]], @"You must return a valid UIImage object for -emptyViewButtonImageInView:forState:");
        return image;
    }
    return nil;
}

- (UIImage *)buttonBackgroundImageForState:(UIControlState)state{
    if (self.emptyDataSource && [self.emptyDataSource respondsToSelector:@selector(emptyViewButtonBackgroundImageInView:forState:)]) {
        UIImage *image = [self.emptyDataSource emptyViewButtonBackgroundImageInView:self forState:state];
        if (image) NSAssert([image isKindOfClass:[UIImage class]], @"You must return a valid UIImage object for -emptyViewButtonBackgroundImageInView:forState:");
        return image;
    }
    return nil;
}

- (UIColor *)emptyBackgroundColor{
    if (self.emptyDataSource && [self.emptyDataSource respondsToSelector:@selector(emptyViewBackgroundColorInView:)]) {
        UIColor *color = [self.emptyDataSource emptyViewBackgroundColorInView:self];
        if (color) NSAssert([color isKindOfClass:[UIColor class]], @"You must return a valid UIColor object for -emptyViewBackgroundColorInView:");
        return color;
    }
    return [UIColor clearColor]; // Defaut
}

- (UIView *)emptyCustomView{
    if (self.emptyDataSource && [self.emptyDataSource respondsToSelector:@selector(emptyViewWithCustomViewInView:)]) {
        UIView *view = [self.emptyDataSource emptyViewWithCustomViewInView:self];
        if (view) NSAssert([view isKindOfClass:[UIView class]], @"You must return a valid UIView object for -emptyViewWithCustomViewInView:");
        return view;
    }
    return nil;
}

- (CGFloat)verticalOffset{
    CGFloat offset = 0.0;
    if (self.emptyDataSource && [self.emptyDataSource respondsToSelector:@selector(emptyViewVerticalOffsetInView:)]) {
        offset = [self.emptyDataSource emptyViewVerticalOffsetInView:self];
    }
    return offset;
}

- (CGFloat)verticalSpace{
    if (self.emptyDataSource && [self.emptyDataSource respondsToSelector:@selector(emptyViewSpaceHeightInView:)]) {
        return [self.emptyDataSource emptyViewSpaceHeightInView:self];
    }
    return 0.0;
}


#pragma mark - DelegateGetters &E vents (Private)
- (BOOL)shouldFadeIn {
    if (self.emptyDelegate && [self.emptyDelegate respondsToSelector:@selector(emptyViewShouldFadeInInView:)]) {
        return [self.emptyDelegate emptyViewShouldFadeInInView:self];
    }
    return YES;
}

- (BOOL)shouldDisplay{
    if (self.emptyDelegate && [self.emptyDelegate respondsToSelector:@selector(emptyViewShouldDisplayInView:)]) {
        return [self.emptyDelegate emptyViewShouldDisplayInView:self];
    }
    return YES;
}

- (BOOL)isTouchAllowed{
    if (self.emptyDelegate && [self.emptyDelegate respondsToSelector:@selector(emptyViewShouldAllowTouchInView:)]) {
        return [self.emptyDelegate emptyViewShouldAllowTouchInView:self];
    }
    return YES;
}

- (BOOL)isScrollAllowed{
    if (self.emptyDelegate && [self.emptyDelegate respondsToSelector:@selector(emptyViewShouldAllowScrollInView:)]) {
        return [self.emptyDelegate emptyViewShouldAllowScrollInView:self];
    }
    return NO;
}

- (BOOL)isImageViewAnimateAllowed{
    if (self.emptyDelegate && [self.emptyDelegate respondsToSelector:@selector(emptyViewShouldAnimateImageViewInView:)]) {
        return [self.emptyDelegate emptyViewShouldAnimateImageViewInView:self];
    }
    return NO;
}

- (void)_willAppear{
    if (self.emptyDelegate && [self.emptyDelegate respondsToSelector:@selector(emptyViewWillAppearInView:)]) {
        [self.emptyDelegate emptyViewWillAppearInView:self];
    }
}

- (void)_didAppear{
    if (self.emptyDelegate && [self.emptyDelegate respondsToSelector:@selector(emptyViewDidAppearInView:)]) {
        [self.emptyDelegate emptyViewDidAppearInView:self];
    }
}

- (void)_willDisappear{
    if (self.emptyDelegate && [self.emptyDelegate respondsToSelector:@selector(emptyViewWillDisappearInView:)]) {
        [self.emptyDelegate emptyViewWillDisappearInView:self];
    }
}

- (void)_didDisappear{
    if (self.emptyDelegate && [self.emptyDelegate respondsToSelector:@selector(emptyViewDidDisappearInView:)]) {
        [self.emptyDelegate emptyViewDidDisappearInView:self];
    }
}

- (void)didTapContentView:(id)sender{
    if (self.emptyDelegate && [self.emptyDelegate respondsToSelector:@selector(emptyViewInView:didClickView:)]) {
        [self.emptyDelegate emptyViewInView:self didClickView:sender];
    }
}

- (void)didClickYJEmptyViewButton:(UIButton *)sender{
    if (self.emptyDelegate && [self.emptyDelegate respondsToSelector:@selector(emptyViewInView:didClickButton:)]) {
        [self.emptyDelegate emptyViewInView:self didClickButton:sender];
    }
}

@end


