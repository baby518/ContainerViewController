//
//  ZCContainerViewController.m
//  ContainerViewControllerDemo
//
//  Created by zhangchao on 15/4/21.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "ContainerViewController.h"
#import "BaseChildViewController.h"

@interface ContainerViewController () <UIScrollViewDelegate>
// use 3 view controllers,  prev<--current-->next
@property(strong, nonatomic) UIViewController *prevViewController;
@property(strong, nonatomic) UIViewController *currentViewController;
@property(strong, nonatomic) UIViewController *nextViewController;
// this index is index of model's viewControllers' index.
@property(assign, nonatomic) NSUInteger index;
// this count must < 3, maybe 1 or 2 or 3;
@property(assign, nonatomic) NSUInteger scrollCount;

@property(strong, nonatomic) UIScrollView *scrollView;
@end

@implementation ContainerViewController

- (NSUInteger)currentIndex {
    return self.index;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    NSLog(@"ContainerViewController viewDidLoad : %f x %f", self.view.frame.size.width, self.view.frame.size.height);

    if (self.useScrollView) {
        _scrollCount = 0;
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
//        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * self.count, self.view.frame.size.height);
        self.scrollView.scrollEnabled = YES;
        self.scrollView.delegate = self;
        self.scrollView.bounces = NO;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.directionalLockEnabled = YES;

        [self.view addSubview:_scrollView];

        // show current view
        CGRect pageViewRect = self.scrollView.bounds;

        // if has prev, set current offset is 1 * width; like it : prev<--current
        // otherwise, set current offset is 0; like it : current-->next
        CGFloat offset = self.prevViewController == nil ? 0 : pageViewRect.size.width;

        [self.scrollView addSubview:self.currentViewController.view];
        self.currentViewController.view.frame = CGRectMake(pageViewRect.origin.x + offset, pageViewRect.origin.y, pageViewRect.size.width, pageViewRect.size.height);
//        NSLog(@"ContainerViewController pageViewRect start : %f,%f , size : %f x %f", pageViewRect.origin.x, pageViewRect.origin.y, pageViewRect.size.width, pageViewRect.size.height);
        _scrollCount++;

        // add prev view
        if (self.prevViewController != nil) {
            [self.scrollView insertSubview:self.prevViewController.view aboveSubview:self.currentViewController.view];
            self.prevViewController.view.frame = CGRectMake(pageViewRect.origin.x - pageViewRect.size.width + offset, pageViewRect.origin.y, pageViewRect.size.width, pageViewRect.size.height);
            _scrollCount++;
        }

        // add next view
        if (self.nextViewController != nil) {
            [self.scrollView insertSubview:self.nextViewController.view belowSubview:self.currentViewController.view];
            self.nextViewController.view.frame = CGRectMake(pageViewRect.origin.x + pageViewRect.size.width + offset, pageViewRect.origin.y, pageViewRect.size.width, pageViewRect.size.height);
            _scrollCount++;
        }

        NSAssert(self.scrollCount <= 3, @"self.scrollCount must be <= 3");
        // set contentSize, max is 3.
        NSLog(@"viewDidLoad scrollCount : %d", self.scrollCount);
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * self.scrollCount, self.view.frame.size.height);

        // set current position.
        [self.scrollView setContentOffset:CGPointMake(pageViewRect.origin.x + offset, pageViewRect.origin.y) animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)getViewControllerFromModel:(BaseModelController *)model atIndex:(NSUInteger)index {
    BaseChildViewController *viewController = [model viewControllerAtIndex:index storyboard:self.storyboard];
    viewController.parentDelegate = self;
    return viewController;
}

- (void)setModelController:(BaseModelController *)modelController startIndex:(NSUInteger)index useScrollView:(BOOL)useScrollView {
    _modelController = modelController;
    _count = self.modelController.count;
    _useScrollView = useScrollView;
    NSLog(@"setModelController : %d/%d", index, self.count);
    if (index >= self.count - 1) {
        _index = self.count - 1;
    } else if (index <= 0) {
        _index = 0;
    } else {
        _index = index;
    }

    _currentViewController = [self getViewControllerFromModel:self.modelController atIndex:self.index];
    [self addChildViewController:self.currentViewController];

    if (self.index >= 1) {
        _prevViewController = [self getViewControllerFromModel:self.modelController atIndex:self.index - 1];
        [self addChildViewController:self.prevViewController];
    }

    if (self.index <= self.count - 2) {
        _nextViewController = [self getViewControllerFromModel:self.modelController atIndex:self.index + 1];
        [self addChildViewController:self.nextViewController];
    }

    if (!self.useScrollView) {
        // show current view
        [self.view addSubview:self.currentViewController.view];

        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        CGRect pageViewRect = self.view.bounds;
        self.currentViewController.view.frame = pageViewRect;

        [self.currentViewController didMoveToParentViewController:self];
    }
}

- (void)setModelController:(BaseModelController *)modelController startIndex:(NSUInteger)index {
    [self setModelController:modelController startIndex:index useScrollView:false];
}

- (void)setModelController:(BaseModelController *)modelController {
    [self setModelController:modelController startIndex:0];
}

#pragma mark - ContainerParentDelegate

- (BOOL)isUseScrollView {
    return self.useScrollView;
}

- (void)swipeToNextViewController {
    if (self.useScrollView) return;
    NSLog(@"swipeToNextViewController");
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
                                    weakSelf.nextViewController = [self getViewControllerFromModel:weakSelf.modelController atIndex:weakSelf.index + 1];
                                    [weakSelf addChildViewController:weakSelf.nextViewController];
                                }

                                NSLog(@"currentViewController %lu", weakSelf.index);
                            }];
}

- (void)swipeToPrevViewController {
    if (self.useScrollView) return;
    NSLog(@"swipeToPrevViewController");
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
                                    weakSelf.prevViewController = [self getViewControllerFromModel:weakSelf.modelController atIndex:weakSelf.index - 1];
                                    [weakSelf addChildViewController:weakSelf.prevViewController];
                                }
                                NSLog(@"currentViewController %lu", weakSelf.index);
                            }];
}

- (void)gotoViewControllerAtIndex:(NSUInteger)index {
    NSLog(@"gotoViewController %lu --> %lu , useScrollView : %d", self.index, index, self.useScrollView);
    if (self.useScrollView) {
        [self scrollToViewControllerAtIndex:index];
    } else {
        if (self.index != index) {
            if (index <= 0) {
                index = 0;
            } else if (index >= self.count - 1) {
                index = self.count - 1;
            }

            [self.currentViewController willMoveToParentViewController:nil];
            [self.currentViewController removeFromParentViewController];

            _currentViewController = [self getViewControllerFromModel:self.modelController atIndex:index];
            [self.currentViewController.view layoutIfNeeded];

            [self addChildViewController:self.currentViewController];
            [self.view addSubview:self.currentViewController.view];
            [self.currentViewController didMoveToParentViewController:self];

            // relocate prev<--cur-->next
            _index = index;
            NSLog(@"currentViewController %lu", self.index);
            if (self.index + 1 <= self.count - 1) {
                _nextViewController = [self getViewControllerFromModel:self.modelController atIndex:self.index + 1];
                [self addChildViewController:self.nextViewController];
            }
            if (self.index - 1 >= 0) {
                _prevViewController = [self getViewControllerFromModel:self.modelController atIndex:self.index - 1];
                [self addChildViewController:self.prevViewController];
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (!self.useScrollView) return;
    NSUInteger index = (NSUInteger) (fabs(scrollView.contentOffset.x) / scrollView.frame.size.width);
    NSLog(@"scrollViewDidEndDecelerating index : %d", index);
//    [self scrollToViewControllerAtIndex:index];
}

- (void)scrollToViewControllerAtIndex:(NSUInteger)index {
    NSLog(@"scrollToViewControllerAtIndex %d --> %d", self.index, index);

    if (self.index != index) {
        if (index <= 0) {
            index = 0;
        } else if (index >= self.count - 1) {
            index = self.count - 1;
        }

        // show current view
        CGRect pageViewRect = self.scrollView.bounds;

        // 1. remove it
        [self.currentViewController.view removeFromSuperview];
        _scrollCount--;

        // 2. create it
        _currentViewController = [self getViewControllerFromModel:self.modelController atIndex:index];
        [self addChildViewController:self.currentViewController];

        // 3. re add it
        [self.scrollView addSubview:self.currentViewController.view];
        self.currentViewController.view.frame = pageViewRect;
        NSLog(@"ContainerViewController pageViewRect start : %f,%f , size : %f x %f", pageViewRect.origin.x, pageViewRect.origin.y, pageViewRect.size.width, pageViewRect.size.height);
        _scrollCount++;

        self.index = index;
        if (self.index >= 1) {
            // 1. remove it
            if (self.prevViewController != nil) {
                [self.prevViewController.view removeFromSuperview];
                _scrollCount--;
            }
            // 2. create it
            _prevViewController = [self getViewControllerFromModel:self.modelController atIndex:self.index - 1];
            [self addChildViewController:self.prevViewController];
            // 3. re add it
            [self.scrollView insertSubview:self.prevViewController.view aboveSubview:self.currentViewController.view];
            self.prevViewController.view.frame = CGRectMake(pageViewRect.origin.x - pageViewRect.size.width, pageViewRect.origin.y, pageViewRect.size.width, pageViewRect.size.height);
            _scrollCount++;
        }

        if (self.index <= self.count - 2) {
            // 1. remove it
            if (self.nextViewController != nil) {
                [self.nextViewController.view removeFromSuperview];
                _scrollCount--;
            }
            // 2. create it
            _nextViewController = [self getViewControllerFromModel:self.modelController atIndex:self.index + 1];
            [self addChildViewController:self.nextViewController];
            // 3. re add it
            [self.scrollView insertSubview:self.nextViewController.view belowSubview:self.currentViewController.view];
            self.nextViewController.view.frame = CGRectMake(pageViewRect.origin.x + pageViewRect.size.width, pageViewRect.origin.y, pageViewRect.size.width, pageViewRect.size.height);
            _scrollCount++;
        }

        NSAssert(self.scrollCount <= 3, @"self.scrollCount must be <= 3");
        // set contentSize, max is 3.
        NSLog(@"scrollToViewControllerAtIndex scrollCount : %d", self.scrollCount);
        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * self.scrollCount, self.view.frame.size.height);
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
