//
//  SimpleModalContainerControllerViewController.m
//  ContainerViewController
//
//  Created by baishiqi on 16/6/27.
//  Copyright © 2016年 baishiqi. All rights reserved.
//

#import "SlideContainerController.h"

typedef enum : NSUInteger {
    SlideDirectionNone,
    SlideDirectionLeft,
    SlideDirectionRight,
} SlideDirection;

@interface SlideContainerController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *viewControllers;

@property (nonatomic, strong) UIViewController *simpleModalViewController;
@property (nonatomic, strong) UIButton *backgroundButton;
@property (nonatomic, assign) NSUInteger selectedIndex;

@property (nonatomic, assign) BOOL directionDidChanged;
@property (nonatomic, assign) BOOL confirmDirection;
@property (nonatomic, assign) CGFloat originPointX;    // 记录滑动开始时scrollView的偏移量
@property (nonatomic, assign) CGFloat prePointX;       // 多次调用scrollViewDidScroll时，记录上次scrollView的偏移量

@property (nonatomic, assign) NSUInteger indexOrigin;  // 记录滑动开始时所在页面的编号
@property (nonatomic, assign) NSUInteger indexCurrent; // 记录滑动过程中在window中展示超过半屏的页面编号
@property (nonatomic, assign) NSUInteger indexWill;
@property (nonatomic, assign) NSUInteger indexDid;

@property (nonatomic, assign) CGFloat distanceToLeft;
@property (nonatomic, assign) CGFloat distanceToRight;

@property (nonatomic, assign) BOOL directionToLeft;
@property (nonatomic, assign) BOOL directionToRight;

@property (nonatomic, assign) BOOL didInvoke;

@property (nonatomic, assign) SlideDirection slideDirection;

@end


@implementation SlideContainerController

#pragma mark - life circle

- (instancetype)initWithViewControllers:(NSArray *)viewControllers
{
    if (self = [super init]) {
        [self initSetup:viewControllers];
    }
    return self;
}

#pragma mark - getter

- (NSMutableArray *)viewControllers
{
    if (!_viewControllers) {
        _viewControllers = [NSMutableArray array];
    }
    return _viewControllers;
}

#pragma mark - setup

- (void)initSetup:(NSArray *)viewControllers
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    
    for (int i= 0; i<viewControllers.count; i++) {
        UIViewController *controller = [viewControllers objectAtIndex:i];
        
        [self addChildViewController:controller];
        
        [controller beginAppearanceTransition:YES animated:NO];
        
        
        controller.view.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0 + i * CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) / 2.0);
        [self.scrollView addSubview:controller.view];
        
        [controller endAppearanceTransition];
        [controller didMoveToParentViewController:self];
        
        [self.viewControllers addObject:controller];
    }
    
    CGFloat width = self.view.bounds.size.width;
    self.scrollView.contentSize = CGSizeMake(width * viewControllers.count, self.view.bounds.size.height);
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = NO;
    
    self.selectedIndex = 1;
    self.scrollView.contentOffset = CGPointMake(self.selectedIndex * CGRectGetWidth(self.view.bounds), 0);
    self.directionToRight = NO;
    self.directionToLeft = NO;
}

- (void)configSelectedIndex:(NSUInteger)index
{
    if (index < self.viewControllers.count) {
        self.selectedIndex = index;
        [self.scrollView setContentOffset:CGPointMake(index * CGRectGetWidth(self.view.bounds), 0) animated:YES];
    }
}
- (void)setControllerSlideEnable:(BOOL)enable
{
    self.scrollView.scrollEnabled = enable;
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    UIViewController *viewController  = nil;
    if (index < self.viewControllers.count) {
        viewController = [self.viewControllers objectAtIndex:index];
    }
    return viewController;
}

- (void)presentSimpleModalViewController:(UIViewController *)viewControllerToPresent
                                animated:(BOOL)animated{
    if (!self.simpleModalViewController && viewControllerToPresent) {
        self.simpleModalViewController = viewControllerToPresent;
        
        [self addChildViewController:viewControllerToPresent];
        
        [viewControllerToPresent beginAppearanceTransition:YES animated:animated];
        
        [self.view addSubview:self.backgroundButton];
        
        viewControllerToPresent.view.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0, CGRectGetHeight(self.view.bounds) / 2.0);
        [self.view addSubview:viewControllerToPresent.view];
        
        if (animated) {
            viewControllerToPresent.view.alpha = 0;
            self.backgroundButton.alpha = 0;
            
            [UIView animateWithDuration:0.3 animations:^{
                viewControllerToPresent.view.alpha = 1;
                self.backgroundButton.alpha = 0.3;
            } completion:^(BOOL finished) {
                [viewControllerToPresent endAppearanceTransition];
                [viewControllerToPresent didMoveToParentViewController:self];
            }];
        } else {
            self.backgroundButton.alpha = 0.3;
            [viewControllerToPresent endAppearanceTransition];
            [viewControllerToPresent didMoveToParentViewController:self];
        }
        
    }
}

- (void)dismissSimpleModalViewControllerAnimated:(BOOL)animated{
    if (self.simpleModalViewController) {
        [self.simpleModalViewController willMoveToParentViewController:nil];
        [self.simpleModalViewController beginAppearanceTransition:NO animated:animated];
        
        if (animated) {
            [UIView animateWithDuration:0.3 animations:^{
                self.backgroundButton.alpha = 0;
                self.simpleModalViewController.view.alpha = 0 ;
            } completion:^(BOOL finished) {
                [self.backgroundButton removeFromSuperview];
                
                [self.simpleModalViewController.view removeFromSuperview];
                self.simpleModalViewController.view.alpha = 1.0;
                [self.simpleModalViewController endAppearanceTransition];
                [self.simpleModalViewController removeFromParentViewController];
                self.simpleModalViewController = nil;
            }];
        } else {
            [self.backgroundButton removeFromSuperview];
            
            [self.simpleModalViewController.view removeFromSuperview];
            self.simpleModalViewController.view.alpha = 1.0;
            [self.simpleModalViewController endAppearanceTransition];
            [self.simpleModalViewController removeFromParentViewController];
            self.simpleModalViewController = nil; 
        } 
    } 
}

#pragma mark - UIScrollViewDelegate
//// any offset changes
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
////    NSLog(@"%s, %@", __func__, NSStringFromCGPoint(scrollView.contentOffset));
//    
//    // 本次调用时的偏移量
//    CGFloat newPointX = scrollView.contentOffset.x;
//    
//    if (newPointX < self.prePointX) {
//        // 小于上一次的值
////        NSLog(@"右滑");
//        
//        if (self.directionToLeft) {
//            NSLog(@"连续右滑");
////            [self output:0];
//            self.distanceToLeft = self.distanceToLeft + fabs(self.prePointX - newPointX);
//            if (self.distanceToLeft > self.distanceToRight) {
//                self.distanceToLeft = self.distanceToLeft - self.distanceToRight;
////                NSLog(@"self.distanceToLeft > self.distanceToRight");
//            } else if (self.distanceToLeft < self.distanceToRight){
//                self.distanceToRight = self.distanceToRight - self.distanceToLeft;
////                NSLog(@"self.distanceToLeft < self.distanceToRight");
//            } else {
////                self.distanceToLeft = 0;
////                self.distanceToRight = 0;
//            }
////            [self output:fabs(self.prePointX - newPointX)];
//        } else {
//            NSLog(@"变右滑");
//            self.directionToLeft = YES;
//            self.distanceToLeft = self.distanceToLeft + fabs(self.prePointX - newPointX);
//            if (self.distanceToLeft > self.distanceToRight) {
//                self.distanceToLeft = self.distanceToLeft - self.distanceToRight;
////                NSLog(@"self.distanceToLeft > self.distanceToRight");
//            } else if (self.distanceToLeft < self.distanceToRight){
//                self.distanceToRight = self.distanceToRight - self.distanceToLeft;
////                NSLog(@"self.distanceToLeft < self.distanceToRight");
//            } else {
////                self.distanceToLeft = 0;
////                self.distanceToRight = 0;
//            }
//            self.directionToRight = NO;
//        }
//        NSLog(@"右滑 %f", self.distanceToLeft);
//        
//        
//        
//        NSInteger index = (int)newPointX / (int)CGRectGetWidth(self.view.bounds);
//        if (index != self.indexWill) {
//            self.indexWill = index;
////            NSLog(@"将要展示第 %i 页", self.indexWill);
//        }
//        
//        self.indexCurrent = (int)newPointX % (int)CGRectGetWidth(self.view.bounds) < 160 ? (int)newPointX / (int)CGRectGetWidth(self.view.bounds) : (int)newPointX / (int)CGRectGetWidth(self.view.bounds) + 1;
//        
//        
//        
//        if (!self.directionDidChanged) {
//            self.directionDidChanged = !self.directionDidChanged;
//        } else {
////            NSLog(@"连续右滑");
//            
//            if (newPointX < self.originPointX) {
//                NSInteger pageNum = (self.originPointX - newPointX) / CGRectGetWidth(self.view.bounds);
////                NSLog(@"连续右滑过 %i 页", pageNum);
//            }
//            
//        }
//        
//    } else if (newPointX > self.prePointX){
//        // 大于上一次的值
////        NSLog(@"左滑");
//        
//        if (self.directionToRight) {
//            NSLog(@"连续左滑");
////            [self output:0];
//            self.distanceToRight = self.distanceToRight + fabs(self.prePointX - newPointX);
//            if (self.distanceToLeft > self.distanceToRight) {
//                self.distanceToLeft = self.distanceToLeft - self.distanceToRight;
////                NSLog(@"self.distanceToLeft > self.distanceToRight");
//            } else if (self.distanceToLeft < self.distanceToRight){
//                self.distanceToRight = self.distanceToRight - self.distanceToLeft;
////                NSLog(@"self.distanceToLeft < self.distanceToRight");
//            } else {
////                self.distanceToLeft = 0;
////                self.distanceToRight = 0;
//            }
////            [self output:fabs(self.prePointX - newPointX)];
//        } else {
//            NSLog(@"变左滑");
//            self.directionToRight = YES;
////            [self output:0];
//            self.distanceToRight = self.distanceToRight + fabs(self.prePointX - newPointX);
//            [self output:fabs(self.prePointX - newPointX)];
//            if (self.distanceToLeft > self.distanceToRight) {
//                self.distanceToLeft = self.distanceToLeft - self.distanceToRight;
////                NSLog(@"self.distanceToLeft > self.distanceToRight");
//            } else if (self.distanceToLeft < self.distanceToRight){
//                self.distanceToRight = self.distanceToRight - self.distanceToLeft;
////                NSLog(@"self.distanceToLeft < self.distanceToRight");
//            } else {
////                self.distanceToLeft = 0;
////                self.distanceToRight = 0;
//            }
//            self.directionToLeft = NO;
//        }
//        NSLog(@"左滑 %f", self.distanceToRight);
//        
//        
//        
//        NSInteger index = (int)(newPointX-0.5) / (int)CGRectGetWidth(self.view.bounds) + 1;
//        if (index != self.indexWill) {
//            self.indexWill = index;
////            NSLog(@"将要展示第 %i 页", self.indexWill);
//        }
//        
//        self.indexCurrent = (int)newPointX % (int)CGRectGetWidth(self.view.bounds) > 160 ? (int)newPointX / (int)CGRectGetWidth(self.view.bounds) + 1 : (int)newPointX / (int)CGRectGetWidth(self.view.bounds);
//        
//        
//        
//        if (self.directionDidChanged) {
////            NSLog(@"连续左滑");
//            
//            if (newPointX > self.originPointX) {
//                NSInteger pageNum = (newPointX - self.originPointX) / CGRectGetWidth(self.view.bounds);
////                NSLog(@"连续左滑过 %i 页", pageNum);
//            }
//        } else {
//            self.directionDidChanged = !self.directionDidChanged;
//        }
//        
//    }
//    self.prePointX = newPointX;
//    
//    
//    NSLog(@"当前在第 %i 页", self.indexCurrent);
//}

// any offset changes
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 本次调用时的偏移量
    CGFloat newPointX = scrollView.contentOffset.x;
    
    if (newPointX < self.prePointX) {
        
        NSInteger pageNew = newPointX / CGRectGetWidth(self.view.bounds);
        NSInteger pageOld = self.prePointX / CGRectGetWidth(self.view.bounds);
        
        if (pageNew > pageOld) {
            NSLog(@"将要切换到第 %i 页", pageNew + 1);
        } else if (pageNew < pageOld) {
            NSLog(@"将要切换到第 %i 页", pageNew);
        }
        
        self.slideDirection = SlideDirectionRight;
        if (self.directionToLeft) {
//            NSLog(@"连续右滑");
            CGFloat deltDistance = self.prePointX - newPointX;
            self.distanceToLeft = self.distanceToLeft + deltDistance;
            if (self.distanceToRight > 0) {
                self.distanceToRight = self.distanceToRight - deltDistance;
            }
            
            
        } else {
//            NSLog(@"变右滑");
            self.directionToLeft = YES;
            self.directionToRight = NO;
            
            CGFloat deltDistance = self.prePointX - newPointX;
            
            self.distanceToLeft = self.distanceToLeft + deltDistance;
            if (self.distanceToRight > 0) {
                self.distanceToRight = self.distanceToRight - deltDistance;
            }
            
            
            
        }
        NSLog(@"右滑 %f", self.distanceToLeft);
        
    } else if (newPointX > self.prePointX){
        
        NSInteger pageNew = (newPointX + CGRectGetWidth(self.view.bounds) - 0.1) / CGRectGetWidth(self.view.bounds);
        NSInteger pageOld = (self.prePointX + CGRectGetWidth(self.view.bounds) - 0.1) / CGRectGetWidth(self.view.bounds);
        
        if (pageNew > pageOld) {
            NSLog(@"将要切换到第 %i 页", pageNew);
        } else if (pageNew < pageOld) {
            NSLog(@"将要切换到第 %i 页", pageNew);
        }
        
        self.slideDirection = SlideDirectionLeft;
        
        if (self.directionToRight) {
//            NSLog(@"连续左滑");
            CGFloat deltDistance = newPointX - self.prePointX;
            self.distanceToRight = self.distanceToRight + deltDistance;
            if (self.distanceToLeft > 0) {
                self.distanceToLeft = self.distanceToLeft - deltDistance;
            }
            
            
            
            
        } else {
//            NSLog(@"变左滑");
            self.directionToRight = YES;
            self.directionToLeft = NO;
            
            CGFloat deltDistance = newPointX - self.prePointX;
            self.distanceToRight = self.distanceToRight + deltDistance;
            if (self.distanceToLeft > 0) {
                self.distanceToLeft = self.distanceToLeft - deltDistance;
            }
            
            
            
            
        }
        NSLog(@"左滑 %f", self.distanceToRight);
        
    }
    
    
    
    
//    NSInteger pageNew = newPointX / CGRectGetWidth(self.view.bounds);
//    NSInteger pageOld = self.prePointX / CGRectGetWidth(self.view.bounds);
//    
//    if (pageNew > pageOld) {
//        NSLog(@"将要切换到第 %i 页", pageNew + 1);
//    } else if (pageNew < pageOld) {
//        NSLog(@"将要切换到第 %i 页", pageNew);
//    }
//    
//    NSInteger pageNew = (newPointX + CGRectGetWidth(self.view.bounds)) / CGRectGetWidth(self.view.bounds);
//    NSInteger pageOld = (self.prePointX + CGRectGetWidth(self.view.bounds) - 1) / CGRectGetWidth(self.view.bounds);
//    
//    if (pageNew > pageOld) {
//        NSLog(@"将要切换到第 %i 页", pageNew);
//    } else if (pageNew < pageOld) {
//        NSLog(@"将要切换到第 %i 页", pageNew);
//    }
    
//    NSLog(@"之前 %f , 当前 %f", self.prePointX, newPointX);
    
    self.prePointX = newPointX;
}

// any zoom scale changes
- (void)scrollViewDidZoom:(UIScrollView *)scrollView NS_AVAILABLE_IOS(3_2)
{
    NSLog(@"%s", __func__);
}

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"%s, %@", __func__, NSStringFromCGPoint(scrollView.contentOffset));
    self.originPointX = scrollView.contentOffset.x;
    self.prePointX = scrollView.contentOffset.x;
    self.directionDidChanged = NO;
    self.distanceToLeft = 0;
    self.distanceToRight = 0;
    
    self.indexOrigin = self.selectedIndex;
    self.indexCurrent = self.selectedIndex;
    
    self.indexWill = self.selectedIndex;
}

// called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0)
{
    NSLog(@"%s, %@, %@", __func__, NSStringFromCGPoint(velocity), NSStringFromCGPoint(*targetContentOffset));
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"%s , %i", __func__, decelerate);
    
    if (!decelerate) {
        self.selectedIndex = scrollView.contentOffset.x / CGRectGetWidth(self.view.bounds);
//        NSLog(@"滑动完成，停在第 %i 页", self.selectedIndex);
        self.directionToLeft = NO;
        self.directionToRight = NO;
        self.slideDirection = SlideDirectionNone;
        self.confirmDirection = NO;
        
        // 调用viewDidAppear
    }
}

// called on finger up as we are moving
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"%s, %@", __func__, NSStringFromCGPoint(scrollView.contentOffset));
}

// called when scroll view grinds to a halt
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"%s", __func__);
    
    self.selectedIndex = scrollView.contentOffset.x / CGRectGetWidth(self.view.bounds);
//    NSLog(@"滑动完成，停在第 %i 页", self.selectedIndex);
    self.directionToLeft = NO;
    self.directionToRight = NO;
    self.slideDirection = SlideDirectionNone;
    self.confirmDirection = NO;
    
    // 调用viewDidAppear
}

// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSLog(@"%s", __func__);
}

// return a view that will be scaled. if delegate returns nil, nothing happens
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    NSLog(@"%s", __func__);
    return nil;
}

// called before the scroll view begins zooming its content
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view NS_AVAILABLE_IOS(3_2)
{
    NSLog(@"%s", __func__);
}

// scale between minimum and maximum. called after any 'bounce' animations
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale
{
    NSLog(@"%s", __func__);
}

// return a yes if you want to scroll to the top. if not defined, assumes YES
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    NSLog(@"%s", __func__);
    return YES;
}

// called when scrolling animation finished. may be called immediately if already at top
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    NSLog(@"%s", __func__);
}

@end


