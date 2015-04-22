//
//  ZCContainerViewController.m
//  ContainerViewControllerDemo
//
//  Created by zhangchao on 15/4/21.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "ContainerViewController.h"

@interface ContainerViewController ()
@property(strong, nonatomic) UIViewController *prevViewController;
@property(strong, nonatomic) UIViewController *currentViewController;
@property(strong, nonatomic) UIViewController *nextViewController;
@property(assign, nonatomic) NSUInteger index;
@end

@implementation ContainerViewController

- (NSUInteger)currentIndex {
    return self.index;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setModelController:(BaseModelController *)modelController startIndex:(NSUInteger)index {
    _modelController = modelController;
    _count = _modelController.count;
    if (index >= _count - 1) {
        _index = _count - 1;
    } else if (index <= 0) {
        _index = 0;
    } else {
        _index = index;
    }

    _currentViewController = [self.modelController viewControllerAtIndex:_index storyboard:self.storyboard];
    [self addChildViewController:self.currentViewController];

    if (_index >= 1) {
        _prevViewController = [self.modelController viewControllerAtIndex:_index - 1 storyboard:self.storyboard];
        //        [self addChildViewController:self._prevViewController];
    }

    if (_index <= _count - 2) {
        _nextViewController = [self.modelController viewControllerAtIndex:_index + 1 storyboard:self.storyboard];
        //        [self addChildViewController:self.nextViewController];
    }

    // show current view
    [self.view addSubview:self.currentViewController.view];

    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    self.currentViewController.view.frame = pageViewRect;

    [self.currentViewController didMoveToParentViewController:self];
}

- (void)setModelController:(BaseModelController *)modelController {
    [self setModelController:modelController startIndex:0];
}

- (void)swapToNextViewController {
    NSLog(@"swapToNextViewController");
    if (self.index >= self.count - 1) {
        self.index = self.count - 1;
        return;
    }
    if (self.nextViewController == nil) {
        return;
    }

    [self.nextViewController.view layoutIfNeeded];

    [self.currentViewController willMoveToParentViewController:nil];
    [self addChildViewController:self.nextViewController];

    __weak __block ContainerViewController *weakSelf = self;
    [self transitionFromViewController:self.currentViewController toViewController:self.nextViewController
                              duration:0.4f
                               options:UIViewAnimationOptionTransitionFlipFromRight
                            animations:nil
                            completion:^(BOOL finished) {
                                [weakSelf.currentViewController removeFromParentViewController];
                                [weakSelf.nextViewController didMoveToParentViewController:weakSelf];

                                weakSelf.prevViewController = weakSelf.currentViewController;
                                weakSelf.currentViewController = weakSelf.nextViewController;
                                weakSelf.index++;
                                if (weakSelf.index >= weakSelf.count - 1) {
                                    weakSelf.nextViewController = nil;
                                } else {
                                    weakSelf.nextViewController = [weakSelf.modelController viewControllerAtIndex:weakSelf.index + 1 storyboard:self.storyboard];
                                }
                                NSLog(@"currentViewController %lu", weakSelf.index);
                            }];
}

- (void)swapToPrevViewController {
    NSLog(@"swapToPrevViewController");
    if (self.index <= 0) {
        self.index = 0;
        return;
    }
    if (self.prevViewController == nil) {
        return;
    }

    [self.prevViewController.view layoutIfNeeded];

    [self.currentViewController willMoveToParentViewController:nil];
    [self addChildViewController:self.prevViewController];

    __weak __block ContainerViewController *weakSelf = self;
    [self transitionFromViewController:self.currentViewController toViewController:self.prevViewController
                              duration:0.4f
                               options:UIViewAnimationOptionTransitionFlipFromLeft
                            animations:nil
                            completion:^(BOOL finished) {
                                [weakSelf.currentViewController removeFromParentViewController];
                                [weakSelf.prevViewController didMoveToParentViewController:weakSelf];

                                weakSelf.nextViewController = weakSelf.currentViewController;
                                weakSelf.currentViewController = weakSelf.prevViewController;
                                weakSelf.index--;
                                if (weakSelf.index <= 0) {
                                    weakSelf.prevViewController = nil;
                                } else {
                                    weakSelf.prevViewController = [weakSelf.modelController viewControllerAtIndex:weakSelf.index - 1 storyboard:self.storyboard];
                                }
                                NSLog(@"currentViewController %lu", weakSelf.index);
                            }];
}

- (void)gotoViewControllerAtIndex:(NSUInteger)index {
    NSLog(@"gotoViewController %lu --> %lu", self.index, index);
    if (self.index != index) {
        if (index <= 0) {
            self.index = 0;
        } else if (index >= self.count - 1) {
            self.index = self.count - 1;
        } else {
            self.index = index;
        }

        UIViewController *tempViewController = [self.modelController viewControllerAtIndex:self.index storyboard:self.storyboard];
        [tempViewController.view layoutIfNeeded];

        [self.currentViewController willMoveToParentViewController:nil];
        [self addChildViewController:tempViewController];

        __weak __block ContainerViewController *weakSelf = self;
        [self transitionFromViewController:self.currentViewController toViewController:tempViewController
                                  duration:0.4f
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:nil
                                completion:^(BOOL finished) {
                                    [weakSelf.currentViewController removeFromParentViewController];

                                    weakSelf.currentViewController = tempViewController;
                                    [weakSelf.currentViewController didMoveToParentViewController:weakSelf];

                                    if (weakSelf.index + 1 <= weakSelf.count - 1) {
                                        weakSelf.nextViewController = [weakSelf.modelController viewControllerAtIndex:weakSelf.index + 1 storyboard:weakSelf.storyboard];
                                    }
                                    if (weakSelf.index - 1 >= 0) {
                                        weakSelf.prevViewController = [weakSelf.modelController viewControllerAtIndex:weakSelf.index - 1 storyboard:weakSelf.storyboard];
                                    }
                                    NSLog(@"currentViewController %lu", weakSelf.index);
                                }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
