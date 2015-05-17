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
@property(strong, nonatomic) UIViewController *currentViewController;
@property(strong, nonatomic) NSMutableArray *viewControllerCacheStack;
@property(strong, nonatomic) NSMutableArray *viewControllerCacheIndex;
@property(assign, nonatomic) NSUInteger MAXCacheSize;
// this index is index of model's viewController' index.
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
    _viewControllerCacheStack = [NSMutableArray array];
    _viewControllerCacheIndex = [NSMutableArray array];
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
    [self.view addSubview:self.scrollView];
    // show all views
    [self showScrollSubViews];
    if (self.navScrollView != nil) {
        [self.view addSubview:self.navScrollView];
    }
    // set default
    self.barTintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        CGFloat startY = self.navigationController.isNavigationBarHidden ? SystemStatusBarHeight : 0.0f;
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, startY + NavigationScrollHeight, self.frameWidth, self.frameHeight - NavigationScrollHeight)];
        _scrollView.contentSize = CGSizeMake(self.frameWidth * self.count, self.frameHeight - NavigationScrollHeight);
        _scrollView.scrollEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.bounces = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.directionalLockEnabled = YES;
    }
    return _scrollView;
}

- (UINavigationScrollView *)navScrollView {
    if (self.count <= 0) return nil;
    if (_navScrollView == nil) {
        CGFloat startY = self.navigationController.isNavigationBarHidden ? SystemStatusBarHeight : 0.0f;
        _navScrollView = [[UINavigationScrollView alloc] initWithFrame:CGRectMake(0.0, startY, self.frameWidth, NavigationScrollHeight) titleArray:self.modelController.titleArray];
        _navScrollView.delegate = self;
        _navScrollView.index = self.currentIndex;
    }
    return _navScrollView;
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

    return viewController;
}
- (void)setModelController:(BaseModelController *)modelController startIndex:(NSUInteger)index cacheSize:(NSUInteger)cacheSize {
    _modelController = modelController;
    _count = self.modelController.count;
    if (cacheSize <= 0) cacheSize = 1;
    if (cacheSize > self.count) cacheSize = self.count;
    _MAXCacheSize = cacheSize;
    NSLog(@"setModelController : %lu/%lu", index, self.count);
    if (index >= self.count - 1) {
        _index = self.count - 1;
    } else if (index <= 0) {
        _index = 0;
    } else {
        _index = index;
    }

    if (self.index >= 1) {
        [self addViewControllerAtIndex:self.index - 1];
    }
    if (self.index + 2 <= self.count) {
        [self addViewControllerAtIndex:self.index + 1];
    }
    [self addViewControllerAtIndex:self.index];
}

- (void)setModelController:(BaseModelController *)modelController startIndex:(NSUInteger)index {
    [self setModelController:modelController startIndex:index cacheSize:5];
}

- (void)setModelController:(BaseModelController *)modelController {
    [self setModelController:modelController startIndex:0];
}

- (void)gotoViewControllerAtIndex:(NSUInteger)index {
    NSLog(@"gotoViewController %lu --> %lu", self.index, index);
    [self scrollToViewControllerAtIndex:index];
}

#pragma mark - used for reuse.

- (void)addViewControllerAtIndex:(NSUInteger)index {
    // if index is in cache, find view controller in cache.
    BOOL isIndexCached = [self.viewControllerCacheIndex containsObject:@(index)];
    if (isIndexCached) {
        NSUInteger indexCached = [self.viewControllerCacheIndex indexOfObject:@(index)];
        UIViewController *viewController = self.viewControllerCacheStack[indexCached];

        [self.viewControllerCacheStack removeObject:viewController];
        [self.viewControllerCacheStack addObject:viewController];
        [self.viewControllerCacheIndex removeObject:@(index)];
        [self.viewControllerCacheIndex addObject:@(index)];
        if (index == self.index) {
            _currentViewController = viewController;
        }
    } else {
        // index is not in cache.
        // count is > MAX cache size, delete first object.
        if (self.viewControllerCacheStack.count >= self.MAXCacheSize) {
            [self.viewControllerCacheIndex removeObject:self.viewControllerCacheIndex.firstObject];
            UIViewController *recycleViewController = self.viewControllerCacheStack.firstObject;
            [self.viewControllerCacheStack removeObject:recycleViewController];

            [recycleViewController removeFromParentViewController];
            [recycleViewController.view removeFromSuperview];
        }
        // create new one
        UIViewController *viewController = [self getViewControllerFromModel:self.modelController atIndex:index];
        if (index == self.index) {
            _currentViewController = viewController;
        }
        [self addChildViewController:viewController];
        [self.viewControllerCacheStack addObject:viewController];
        [self.viewControllerCacheIndex addObject:@(index)];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView == self.scrollView) {
        NSUInteger scrollIndex = (unsigned long) (targetContentOffset->x / scrollView.frame.size.width);
        if (self.navScrollView != nil) {
            [self.navScrollView highLightIndex:scrollIndex];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        NSUInteger scrollIndex = (unsigned long)(fabs(scrollView.contentOffset.x) / scrollView.frame.size.width);

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
    if (self.index != index) {
        if (index <= 0) {
            index = 0;
        } else if (index + 1 >= self.count) {
            index = self.count - 1;
        }

        self.index = index;

        if (index >= 1) {
            [self addViewControllerAtIndex:index - 1];
        }
        if (index + 2 <= self.count) {
            [self addViewControllerAtIndex:index + 1];
        }
        [self addViewControllerAtIndex:index];
        // show all views
        [self showScrollSubViews];
    }
}

- (void)showScrollSubViews {
    NSUInteger count = self.viewControllerCacheIndex.count;
    CGRect pageViewRect = self.scrollView.bounds;
    CGFloat startX = 0;
    for (NSUInteger i = 0; i < count; i++) {
        NSUInteger index = ((NSNumber *) self.viewControllerCacheIndex[i]).unsignedIntegerValue;
        CGFloat offsetX = startX + pageViewRect.size.width * index;
        UIViewController *viewController = self.viewControllerCacheStack[i];
        viewController.view.frame = CGRectMake(offsetX, pageViewRect.origin.y, pageViewRect.size.width, pageViewRect.size.height);
        [self.scrollView addSubview:viewController.view];
    }

    // set current position.
    CGFloat offsetX = startX + pageViewRect.size.width * self.index;
    [self.scrollView setContentOffset:CGPointMake(offsetX, pageViewRect.origin.y) animated:NO];
    UIViewController *viewController = self.viewControllerCacheStack.lastObject;
    [self viewDidBringToFront:viewController atIndex:self.index];
}

- (void)viewDidBringToFront:(UIViewController *)viewController atIndex:(NSUInteger)index {
    if (self.navScrollView != nil) {
        [self.navScrollView setIndex:index];
    }
}

#pragma mark - ScrollView
- (void)setupScrollModel {
    NSLog(@"ContainerViewController setupScrollView");
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
