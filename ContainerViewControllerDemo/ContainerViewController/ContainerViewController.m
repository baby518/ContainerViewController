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
@property(strong, nonatomic) UIViewController *prevViewController;
@property(strong, nonatomic) UIViewController *currentViewController;
@property(strong, nonatomic) UIViewController *nextViewController;
@property(assign, nonatomic) NSUInteger index;

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
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
        _scrollView.contentSize = CGSizeMake(self.view.frame.size.width * self.count, self.view.frame.size.height);
        _scrollView.scrollEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.bounces = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.directionalLockEnabled = YES;

        [self.view addSubview:_scrollView];

        // show current view
        [self.scrollView addSubview:self.currentViewController.view];
        CGRect pageViewRect = self.scrollView.bounds;
        self.currentViewController.view.frame = pageViewRect;
        NSLog(@"ContainerViewController pageViewRect start : %f,%f , size : %f x %f", pageViewRect.origin.x, pageViewRect.origin.y, pageViewRect.size.width, pageViewRect.size.height);

        [self.scrollView addSubview:self.nextViewController.view];
        self.nextViewController.view.frame = CGRectMake(pageViewRect.origin.x + pageViewRect.size.width, pageViewRect.origin.y, pageViewRect.size.width, pageViewRect.size.height);

        [self.scrollView setContentOffset:CGPointMake(self.index * pageViewRect.size.width, 0) animated:YES];
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

- (void)setModelController:(BaseModelController *)modelController startIndex:(NSUInteger)index useScrollView:(BOOL)useScrollView{
    _modelController = modelController;
    _count = _modelController.count;
    _useScrollView = useScrollView;
    NSLog(@"setModelController count : %d", _count);
    if (index >= _count - 1) {
        _index = _count - 1;
    } else if (index <= 0) {
        _index = 0;
    } else {
        _index = index;
    }

    _currentViewController = [self getViewControllerFromModel:self.modelController atIndex:_index];
    [self addChildViewController:self.currentViewController];

    if (_index >= 1) {
        _prevViewController = [self getViewControllerFromModel:self.modelController atIndex:_index - 1];
        [self addChildViewController:_prevViewController];
    }

    if (_index <= _count - 2) {
        _nextViewController = [self getViewControllerFromModel:self.modelController atIndex:_index + 1];
        [self addChildViewController:_nextViewController];
    }

    if (!self.useScrollView) {
        // show current view
        [self.view addSubview:self.currentViewController.view];

        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        CGRect pageViewRect = self.view.bounds;
        self.currentViewController.view.frame = pageViewRect;
    }

    [self.currentViewController didMoveToParentViewController:self];
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
    if (self.useScrollView) return;
    NSLog(@"gotoViewController %lu --> %lu", self.index, index);
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
        self.index = index;
        NSLog(@"currentViewController %lu", self.index);
        if (self.index + 1 <= self.count - 1) {
            self.nextViewController = [self getViewControllerFromModel:self.modelController atIndex:self.index + 1];
            [self addChildViewController:self.nextViewController];
        }
        if (self.index - 1 >= 0) {
            self.prevViewController = [self getViewControllerFromModel:self.modelController atIndex:self.index - 1];
            [self addChildViewController:self.prevViewController];
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (!self.useScrollView) return;
    NSUInteger index = (NSUInteger) (fabs(scrollView.contentOffset.x) / scrollView.frame.size.width);
    NSLog(@"scrollViewDidEndDecelerating index : %d", index);
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
