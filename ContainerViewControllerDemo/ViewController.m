//
//  ViewController.m
//  ContainerViewControllerDemo
//
//  Created by zhangchao on 15/4/21.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    DemoModelController *modelController = [[DemoModelController alloc] init];
    _containerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ContainerViewController"];

//    self.containerViewController.modelController = modelController;
//    [self.containerViewController setModelController:modelController startIndex:4];
//    [self.containerViewController setModelController:modelController startIndex:4 useScrollView:YES];
    [self.containerViewController setModelController:modelController startIndex:6 useScrollView:YES useLargeReuse:YES];

    [self addChildViewController:self.containerViewController];
    [self.view addSubview:self.containerViewController.view];

    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    self.containerViewController.view.frame = pageViewRect;

    [self.containerViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
