//
//  UIViewController+SimpleModalContainerController.h
//  ContainerViewController
//
//  Created by baishiqi on 16/6/27.
//  Copyright © 2016年 baishiqi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideContainerController.h"

@interface UIViewController (SimpleModalContainerController)
@property (nonatomic, readonly) SlideContainerController *simpleModalContainerController;
@end
