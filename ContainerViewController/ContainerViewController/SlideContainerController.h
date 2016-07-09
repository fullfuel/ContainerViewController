//
//  SimpleModalContainerControllerViewController.h
//  ContainerViewController
//
//  Created by baishiqi on 16/6/27.
//  Copyright © 2016年 baishiqi. All rights reserved.
//

#import "BaseContainerViewController.h"

@protocol SlideContainerControllerDelegate;

@interface SlideContainerController : BaseContainerViewController

@property (nonatomic, weak) id<SlideContainerControllerDelegate> delegate;

- (instancetype)initWithViewControllers:(NSArray *)viewControllers;
- (void)configSelectedIndex:(NSUInteger)index animated:(BOOL)animated;
- (UIViewController *)viewControllerAtIndex:(NSUInteger)index;
- (void)configControllerSlideEnable:(BOOL)enable;


- (void)presentSimpleModalViewController:(UIViewController *)viewControllerToPresent
                                animated:(BOOL)animated;
- (void)dismissSimpleModalViewControllerAnimated:(BOOL)animated;

@end


@protocol SlideContainerControllerDelegate <NSObject>
@required
- (void)slideContainerController:(SlideContainerController *)slideContainerController willSelectViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController;
- (void)slideContainerController:(SlideContainerController *)slideContainerController didSelectViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController;
@end

//@interface UIViewController (UITabBarControllerItem)
//
//@property(null_resettable, nonatomic, strong) UITabBarItem *tabBarItem; // Automatically created lazily with the view controller's title if it's not set explicitly.
//
//@property(nullable, nonatomic, readonly, strong) UITabBarController *tabBarController; // If the view controller has a tab bar controller as its ancestor, return it. Returns nil otherwise.
//
//@end
