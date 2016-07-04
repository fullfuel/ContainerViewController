//
//  UIViewController+SimpleModalContainerController.m
//  ContainerViewController
//
//  Created by baishiqi on 16/6/27.
//  Copyright © 2016年 baishiqi. All rights reserved.
//

#import "UIViewController+SimpleModalContainerController.h"

@implementation UIViewController (SimpleModalContainerController)

- (SlideContainerController *)simpleModalContainerController{
    for (UIViewController *viewController = self.parentViewController; viewController != nil; viewController = viewController.parentViewController) {
        if ([viewController isKindOfClass:[SlideContainerController class]]) {
            return (SlideContainerController *)viewController;
        }
    }
    return nil;
}

@end
