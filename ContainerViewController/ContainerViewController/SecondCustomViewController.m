//
//  SecondCustomViewController.m
//  ContainerViewController
//
//  Created by baishiqi on 16/6/27.
//  Copyright © 2016年 baishiqi. All rights reserved.
//

#import "SecondCustomViewController.h"
#import "SlideContainerController.h"
#import "ControllerCoordinator.h"

@implementation SecondCustomViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(CGRectGetWidth(self.view.bounds)/2 - 40, CGRectGetHeight(self.view.bounds)/2 - 20, 80, 40);
    button.backgroundColor = [UIColor blackColor];
    button.titleLabel.text = @"Click";
    button.titleLabel.textColor = [UIColor whiteColor];
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)buttonClicked:(UIButton *)btn
{
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor grayColor];
    
    [[ControllerCoordinator shareInstance] configSelectedIndex:0];
    UINavigationController *nav = (UINavigationController *)[[ControllerCoordinator shareInstance] viewControllerAtIndex:0];
    [nav pushViewController:vc animated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

@end
