//
//  ZCContainerViewController.m
//  ContainerViewControllerDemo
//
//  Created by zhangchao on 15/4/21.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "ContainerViewController.h"
#import "UINavigationScrollView.h"

/*
* override UIScrollView shouldRecognizeSimultaneouslyWithGestureRecognizer,
* make UIScreenEdgePanGestureRecognizer enable.*/
@interface UIScrollView (AllowEdgePanGesture)
@end

@implementation UIScrollView (AllowEdgePanGesture)
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
            && [otherGestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]];
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return YES;
//}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
//            && [otherGestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]];
//}
@end

CGFloat const SystemStatusBarHeight = 20.0;
CGFloat const NavigationScrollHeight = 32.0;

@interface ContainerViewController () <UIScrollViewDelegate, UINavigationScrollDelegate>
@property(nonatomic, assign) BOOL useLargeReuse;
// use 3 view controllers,  prev<--current-->next
// if useLargeReuseCount, has 5 view controllers,  prevPrev<--prev<--current-->next-->nextNext
@property(strong, nonatomic) UIViewController *prevPrevViewController;
@property(strong, nonatomic) UIViewController *prevViewController;
@property(strong, nonatomic) UIViewController *currentViewController;
@property(strong, nonatomic) UIViewController *nextViewController;
@property(strong, nonatomic) UIViewController *nextNextViewController;
// this index is index of model's viewControllers' index.
@property(assign, nonatomic) NSUInteger index;
@property(assign, nonatomic) CGFloat frameWidth;
@property(assign, nonatomic) CGFloat frameHeight;
@property(assign, nonatomic) CGFloat SystemNavigationBarHeight;

// root scroll view
@property(strong, nonatomic) UIScrollView *scrollView;
// used for navigation
@property(strong, nonatomic) UINavigationScrollView *navScrollView;
@end

@implementation ContainerViewController

- (void)awakeFromNib {
    [self setupScrollModel];
    NSLog(@"ContainerViewController awakeFromNib");
    // avoid offset
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGFloat startY = self.navigationController.isNavigationBarHidden ? SystemStatusBarHeight : 0.0f;
    if (self.useScrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, startY + NavigationScrollHeight, self.frameWidth, self.frameHeight - NavigationScrollHeight)];
        self.scrollView.contentSize = CGSizeMake(self.frameWidth * self.count, self.frameHeight - NavigationScrollHeight);
        self.scrollView.scrollEnabled = YES;
        self.scrollView.delegate = self;
        self.scrollView.bounces = NO;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.directionalLockEnabled = YES;

        [self.view addSubview:self.scrollView];

        // show all views
        [self relocateViewController];
    }

    if (self.count > 0) {
        _navScrollView = [[UINavigationScrollView alloc] initWithFrame:CGRectMake(0.0, startY, self.frameWidth, NavigationScrollHeight) titleArray:self.modelController.titleArray];
        self.navScrollView.delegate = self;
        self.navScrollView.index = self.currentIndex;
        [self.view addSubview:self.navScrollView];
    }

    // set default
    self.barTintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)currentIndex {
    return self.index;
}

- (CGFloat)frameWidth {
    return self.view.frame.size.width;
}

- (CGFloat)frameHeight {
    return self.view.frame.size.height - self.SystemNavigationBarHeight - SystemStatusBarHeight;
}

- (CGFloat)SystemNavigationBarHeight {
    if (self.navigationController.isNavigationBarHidden) {
        return 0.0;
    } else {
        return self.navigationController.navigationBar.frame.size.height;
    }
}

- (void)setBarTintColor:(UIColor *)barTintColor {
    _barTintColor = barTintColor;
    // I want navigationBar and navScrollView keep a same color.
//    self.navigationController.navigationBar.translucent = NO;
//    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
//        // Load resources for iOS 6.1 or earlier
//        self.navigationController.navigationBar.tintColor = self.barTintColor;
//    } else {
//        // Load resources for iOS 7 or later
//        self.navigationController.navigationBar.barTintColor = self.barTintColor;
//    }
    if (self.navScrollView != nil) {
        [self.navScrollView setBarTintColor:self.barTintColor];
    }
}

- (UIViewController *)getViewControllerFromModel:(BaseModelController *)model atIndex:(NSUInteger)index {
    NSLog(@"getViewControllerFromModel : %lu", index);
    UIViewController *viewController = [model viewControllerAtIndex:index storyboard:self.storyboard];

    if (!self.useScrollView) {
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [viewController.view addGestureRecognizer:swipeLeft];
        
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [viewController.view addGestureRecognizer:swipeRight];
    }
    
    return viewController;
}

- (void)setModelController:(BaseModelController *)modelController startIndex:(NSUInteger)index useScrollView:(BOOL)useScrollView useLargeReuse:(BOOL)useLargeReuse {
    _modelController = modelController;
    _count = self.modelController.count;
    _useScrollView = useScrollView;
    _useLargeReuse = useLargeReuse;
    NSLog(@"setModelController : %lu/%lu", index, self.count);
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

    if (self.useLargeReuse && self.index >= 2) {
        _prevPrevViewController = [self getViewControllerFromModel:self.modelController atIndex:self.index - 2];
        [self addChildViewController:self.prevPrevViewController];
    }

    if (self.index + 2 <= self.count) {
        _nextViewController = [self getViewControllerFromModel:self.modelController atIndex:self.index + 1];
        [self addChildViewController:self.nextViewController];
    }

    if (self.useLargeReuse && self.index + 3 <= self.count) {
        _nextNextViewController = [self getViewControllerFromModel:self.modelController atIndex:self.index + 2];
        [self addChildViewController:self.nextNextViewController];
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

- (void)setModelController:(BaseModelController *)modelController startIndex:(NSUInteger)index useScrollView:(BOOL)useScrollView {
    [self setModelController:modelController startIndex:index useScrollView:useScrollView useLargeReuse:false];
}

- (void)setModelController:(BaseModelController *)modelController startIndex:(NSUInteger)index {
    [self setModelController:modelController startIndex:index useScrollView:false];
}

- (void)setModelController:(BaseModelController *)modelController {
    [self setModelController:modelController startIndex:0];
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
            } else if (index + 1 >= self.count) {
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
            if (self.index + 2 <= self.count) {
                _nextViewController = [self getViewControllerFromModel:self.modelController atIndex:self.index + 1];
                [self addChildViewController:self.nextViewController];
            }
            if (self.index >= 1) {
                _prevViewController = [self getViewControllerFromModel:self.modelController atIndex:self.index - 1];
                [self addChildViewController:self.prevViewController];
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        if (!self.useScrollView) return;
        NSUInteger scrollIndex = (NSUInteger) (fabs(scrollView.contentOffset.x) / scrollView.frame.size.width);
        NSLog(@"scrollViewDidEndDecelerating %lu --> %lu", self.index, scrollIndex);
        
        if (scrollIndex > self.index) {
            // to right
            [self scrollToViewControllerAtIndex:scrollIndex];
        } else if (scrollIndex < self.index) {
            // to left
            [self scrollToViewControllerAtIndex:scrollIndex];
        }
    }
}

- (void)scrollToViewControllerAtIndex:(NSUInteger)index {
    NSLog(@"scrollToViewControllerAtIndex %lu --> %lu", self.index, index);

    if (self.index != index) {
        if (index <= 0) {
            index = 0;
        } else if (index + 1 >= self.count) {
            index = self.count - 1;
        }

        // get all views need
        // 1. remove it
        [self.currentViewController.view removeFromSuperview];
        if (self.nextViewController != nil) {
            [self.nextViewController removeFromParentViewController];
            [self.nextViewController.view removeFromSuperview];
        }
        if (self.prevViewController != nil) {
            [self.prevViewController removeFromParentViewController];
            [self.prevViewController.view removeFromSuperview];
        }
        if (self.useLargeReuse) {
            if (self.nextNextViewController != nil) {
                [self.nextNextViewController removeFromParentViewController];
                [self.nextNextViewController.view removeFromSuperview];
            }
            if (self.prevPrevViewController != nil) {
                [self.prevPrevViewController removeFromParentViewController];
                [self.prevPrevViewController.view removeFromSuperview];
            }
        }

        // 2. create it
        if (self.useLargeReuse && index == self.index + 2) {
            _prevPrevViewController = self.currentViewController;
            _prevViewController = self.nextViewController;
            _currentViewController = self.nextNextViewController;
            if (index + 2 <= self.count) {
                _nextViewController = [self getViewControllerFromModel:self.modelController atIndex:index + 1];
            } else {
                _nextViewController = nil;
            }
            if (index + 3 <= self.count) {
                _nextNextViewController = [self getViewControllerFromModel:self.modelController atIndex:index + 2];
            } else {
                _nextNextViewController = nil;
            }
        } else if (index == self.index + 1) {
            if (self.useLargeReuse) {
                _prevPrevViewController = self.prevViewController;
            }
            _prevViewController = self.currentViewController;
            _currentViewController = self.nextViewController;
            if (index + 2 <= self.count) {
                if (self.useLargeReuse) {
                    _nextViewController = self.nextNextViewController;
                    if (index + 3 <= self.count) {
                        _nextNextViewController = [self getViewControllerFromModel:self.modelController atIndex:index + 2];
                    } else {
                        _nextNextViewController = nil;
                    }
                } else {
                    _nextViewController = [self getViewControllerFromModel:self.modelController atIndex:index + 1];
                }
            } else {
                _nextViewController = nil;
            }
        } else if (index + 1 == self.index) {
            if (self.useLargeReuse) {
                _nextNextViewController = self.nextViewController;
            }
            _nextViewController = self.currentViewController;
            _currentViewController = self.prevViewController;
            if (index >= 1) {
                if (self.useLargeReuse) {
                    _prevViewController = self.prevPrevViewController;
                    if (index >= 2) {
                        _prevPrevViewController = [self getViewControllerFromModel:self.modelController atIndex:index - 2];
                    } else {
                        _prevPrevViewController = nil;
                    }
                } else {
                    _prevViewController = [self getViewControllerFromModel:self.modelController atIndex:index - 1];
                }
            } else {
                _prevViewController = nil;
            }
        } else if (self.useLargeReuse && index + 2 == self.index) {
            _nextNextViewController = self.currentViewController;
            _nextViewController = self.prevViewController;
            _currentViewController = self.prevPrevViewController;
            if (index >= 1) {
                _prevViewController = [self getViewControllerFromModel:self.modelController atIndex:index - 1];
            } else {
                _prevViewController = nil;
            }
            if (index >= 2) {
                _prevPrevViewController = [self getViewControllerFromModel:self.modelController atIndex:index - 2];
            } else {
                _prevPrevViewController = nil;
            }
        } else {
            _currentViewController = [self getViewControllerFromModel:self.modelController atIndex:index];
            if (self.useLargeReuse && index + 3 <= self.count) {
                _nextNextViewController = [self getViewControllerFromModel:self.modelController atIndex:index + 2];
            } else {
                _nextNextViewController = nil;
            }
            if (index + 2 <= self.count) {
                _nextViewController = [self getViewControllerFromModel:self.modelController atIndex:index + 1];
            } else {
                _nextViewController = nil;
            }
            if (index >= 1) {
                _prevViewController = [self getViewControllerFromModel:self.modelController atIndex:index - 1];
            } else {
                _prevViewController = nil;
            }
            if (self.useLargeReuse && index >= 2) {
                _prevPrevViewController = [self getViewControllerFromModel:self.modelController atIndex:index - 2];
            } else {
                _prevPrevViewController = nil;
            }
        }

        // 4. add them in parent's controller
        [self addChildViewController:self.currentViewController];
        if (self.nextViewController != nil) {
            [self addChildViewController:self.nextViewController];
        }
        if (self.prevViewController != nil) {
            [self addChildViewController:self.prevViewController];
        }
        if (self.useLargeReuse) {
            if (self.nextNextViewController != nil) {
                [self addChildViewController:self.nextNextViewController];
            }
            if (self.prevPrevViewController != nil) {
                [self addChildViewController:self.prevPrevViewController];
            }
        }

        self.index = index;

        // show all views
        [self relocateViewController];
    }
}

- (void)relocateViewController {
    // reset current position to 0,0 first.
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];

    CGRect pageViewRect = self.scrollView.bounds;

    // if has prev, set current offset is index * width; like it : prev<--current
    // otherwise, set current offset is 0; like it : current-->next

    CGFloat offset = self.prevViewController != nil ? pageViewRect.origin.x + pageViewRect.size.width * self.index : pageViewRect.origin.x;
    // 3. add all view
    [self.scrollView addSubview:self.currentViewController.view];
    self.currentViewController.view.frame = CGRectMake(offset, pageViewRect.origin.y, pageViewRect.size.width, pageViewRect.size.height);

    [self viewDidBringToFront:self.index];

    // add prev view
    if (self.prevViewController != nil) {
        [self.scrollView insertSubview:self.prevViewController.view aboveSubview:self.currentViewController.view];
        self.prevViewController.view.frame = CGRectMake(offset - pageViewRect.size.width, pageViewRect.origin.y, pageViewRect.size.width, pageViewRect.size.height);
    }

    // add prevPrev view
    if (self.useLargeReuse && self.prevPrevViewController != nil) {
        [self.scrollView insertSubview:self.prevPrevViewController.view aboveSubview:self.prevViewController.view];
        self.prevPrevViewController.view.frame = CGRectMake(offset - pageViewRect.size.width * 2, pageViewRect.origin.y, pageViewRect.size.width, pageViewRect.size.height);
    }

    // add next view
    if (self.nextViewController != nil) {
        [self.scrollView insertSubview:self.nextViewController.view belowSubview:self.currentViewController.view];
        self.nextViewController.view.frame = CGRectMake(offset + pageViewRect.size.width, pageViewRect.origin.y, pageViewRect.size.width, pageViewRect.size.height);
    }

    // add nextNext view
    if (self.nextNextViewController != nil) {
        [self.scrollView insertSubview:self.nextNextViewController.view belowSubview:self.nextViewController.view];
        self.nextNextViewController.view.frame = CGRectMake(offset + pageViewRect.size.width * 2, pageViewRect.origin.y, pageViewRect.size.width, pageViewRect.size.height);
    }

    // set current position.
    [self.scrollView setContentOffset:CGPointMake(offset, pageViewRect.origin.y) animated:NO];
}

- (void)viewDidBringToFront:(NSUInteger)index {
    if (self.navScrollView != nil) {
        [self.navScrollView setIndex:index];
    }
}

#pragma mark - ScrollView
- (void)setupScrollModel {
    NSLog(@"ContainerViewController setupScrollView");
}

#pragma mark - Handle Gesture
- (void)handleSwipeGesture:(UIGestureRecognizer *)gestureRecognizer {
    //    NSLog(@"handleSwipeGesture %@", gestureRecognizer.description);
    if ([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
        if (((UISwipeGestureRecognizer *) gestureRecognizer).direction == UISwipeGestureRecognizerDirectionRight) {
            [self swipeToPrevViewController];
        } else if (((UISwipeGestureRecognizer *) gestureRecognizer).direction == UISwipeGestureRecognizerDirectionLeft) {
            [self swipeToNextViewController];
        }
    }
}

#pragma mark - UINavigationScrollDelegate
- (void)indexChanged:(NSUInteger)index {
    [self gotoViewControllerAtIndex:index];
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
