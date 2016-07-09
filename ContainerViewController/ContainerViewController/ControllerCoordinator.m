//
//  ControllerCoordinator.m
//  ContainerViewController
//
//  Created by baishiqi on 16/6/28.
//  Copyright © 2016年 baishiqi. All rights reserved.
//

#import "ControllerCoordinator.h"
#import "SlideContainerController.h"
#import "AppDelegate.h"

@interface ControllerCoordinator ()

@property (nonatomic, strong) SlideContainerController *controller;

@end

@implementation ControllerCoordinator

static ControllerCoordinator *coordinator;

+ (ControllerCoordinator *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coordinator = [[ControllerCoordinator alloc] init];
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        coordinator.controller = (SlideContainerController *)delegate.window.rootViewController;
    });
    return coordinator;
}

- (void)configSelectedIndex:(NSUInteger)index animated:(BOOL)animated
{
    [self.controller configSelectedIndex:index animated:animated];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    return [self.controller viewControllerAtIndex:index];
}

- (void)configControllerSlideEnable:(BOOL)enable
{
    if (self.controller) {
        [self.controller configControllerSlideEnable:enable];
    }
}

@end
