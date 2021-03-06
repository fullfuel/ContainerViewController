//
//  ControllerCoordinator.h
//  ContainerViewController
//
//  Created by baishiqi on 16/6/28.
//  Copyright © 2016年 baishiqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ControllerCoordinator : NSObject

+ (ControllerCoordinator *)shareInstance;

- (void)configSelectedIndex:(NSUInteger)index animated:(BOOL)animated;

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index;

- (void)configControllerSlideEnable:(BOOL)enable;

@end
