//
//  ZCContainerViewController.m
//  ContainerViewControllerDemo
//
//  Created by zhangchao on 15/4/21.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "ContainerViewController.h"
#import "UINavigationScrollView.h"

CGFloat const SystemStatusBarHeight = 20.0;
CGFloat const DefaultNavigationScrollHeight = 32.0;

@interface ContainerViewController () <UIScrollViewDelegate, UINavigationScrollDelegate, ModelControllerDelegate>
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
    _navigationScrollHeight = DefaultNavigationScrollHeight;
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
    // set default
    self.barTintColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];

    [self rebuildScrollSubViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setModelController:(BaseModelController *)modelController {
    _modelController = modelController;
    _modelController.delegate = self;
}

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        CGFloat startY = self.navigationController.isNavigationBarHidden ? SystemStatusBarHeight : 0.0f;
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, startY + self.navigationScrollHeight, self.frameWidth, self.frameHeight - self.navigationScrollHeight)];
        _scrollView.contentSize = CGSizeMake(self.frameWidth * self.count, self.frameHeight - self.navigationScrollHeight);
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
    if (_navScrollView == nil) {
        CGFloat startY = self.navigationController.isNavigationBarHidden ? SystemStatusBarHeight : 0.0f;
        _navScrollView = [[UINavigationScrollView alloc] initWithFrame:CGRectMake(0.0, startY, self.frameWidth, self.navigationScrollHeight) titleArray:self.modelController.titleArray];
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

- (NSUInteger)MAXCacheSize {
    if (_MAXCacheSize == 0) {
        _MAXCacheSize = self.count;
    }
    return _MAXCacheSize;
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

//    if (self.navScrollView != nil) {
//        [self.navScrollView setBarTintColor:self.barTintColor];
//    }
}

- (UIViewController *)getViewControllerFromModel:(BaseModelController *)model atIndex:(NSUInteger)index {
    NSLog(@"getViewControllerFromModel : %lu", index);
    UIViewController *viewController = [model viewControllerAtIndex:index storyboard:self.storyboard];

    return viewController;
}

- (NSUInteger)count {
    return self.modelController.count;
}

- (void)gotoViewControllerAtIndex:(NSUInteger)index {
    NSLog(@"gotoViewController %lu --> %lu", self.index, index);
    [self scrollToViewControllerAtIndex:index];
}

#pragma mark - used for reuse.
- (void)deleteAllCacheStack {
    // clear all
    for (UIViewController *viewController in self.viewControllerCacheStack) {
        [viewController removeFromParentViewController];
        [viewController.view removeFromSuperview];
    }

    [self.viewControllerCacheStack removeAllObjects];
    [self.viewControllerCacheIndex removeAllObjects];
}

- (void)rebuildCacheStack {
    [self rebuildCacheStack:self.index];
}

- (void)rebuildCacheStack:(NSUInteger)startIndex {
    [self rebuildCacheStack:startIndex withCacheSize:self.MAXCacheSize];
}

- (void)rebuildCacheStack:(NSUInteger)startIndex withCacheSize:(NSUInteger)cacheSize {
    if (cacheSize <= 0) cacheSize = 0;
    if (cacheSize > self.count) cacheSize = self.count;
    _MAXCacheSize = cacheSize;
    NSLog(@"rebuildCacheStack startIndex : %lu/%lu, cache : %ld", self.index, self.count, cacheSize);

    if (startIndex >= self.count - 1) {
        _index = self.count - 1;
    } else if (startIndex <= 0) {
        _index = 0;
    } else {
        _index = startIndex;
    }

    if (self.count != 0) {
        if (self.index >= 1) {
            [self addViewControllerAtIndex:self.index - 1];
        }
        if (self.index + 2 <= self.count) {
            [self addViewControllerAtIndex:self.index + 1];
        }
        [self addViewControllerAtIndex:self.index];
        // clear other.
    } else {
        [self deleteAllCacheStack];
    }
}

/** add viewController in cache. */
- (void)addViewControllerAtIndex:(NSUInteger)index {
    // if index is in cache, find view controller in cache.
    BOOL isIndexCached = [self.viewControllerCacheIndex containsObject:@(index)];
    if (isIndexCached) {
        NSUInteger indexCached = [self.viewControllerCacheIndex indexOfObject:@(index)];
        UIViewController *viewController = self.viewControllerCacheStack[indexCached];

        // move current object to last index.
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
        if (viewController != nil) {
            if (index == self.index) {
                _currentViewController = viewController;
            }
            [self addChildViewController:viewController];
            [self.viewControllerCacheStack addObject:viewController];
            [self.viewControllerCacheIndex addObject:@(index)];
        } else {
            [self addChildViewController:[[UIViewController alloc] init]];
        }
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

        // current viewController return to back's callback.
        [self viewDidReturnToBack:self.currentViewController atIndex:self.index];

        self.index = index;

        [self rebuildCacheStack];
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

- (void)viewDidReturnToBack:(UIViewController *)viewController atIndex:(NSUInteger)index {
}

#pragma mark - ScrollView

- (void)rebuildScrollSubViews {
    // show all views
    [self showScrollSubViews];
    if (self.navScrollView != nil) {
        // set nil to re init if not same.
        if (self.navScrollView.titleCount != self.count) {
            [self.navScrollView removeFromSuperview];
            _navScrollView = nil;
        }
        [self.view addSubview:self.navScrollView];
    }
}

- (void)setupScrollModel {
    NSLog(@"ContainerViewController setupScrollView");
}

#pragma mark - UINavigationScrollDelegate
- (void)indexChanged:(NSUInteger)index {
    [self gotoViewControllerAtIndex:index];
}

#pragma mark - ModelControllerDelegate
- (void)modelCountChanged:(NSUInteger)prevCount :(NSUInteger)currCount {
    NSLog(@"modelCountChanged %ld --> %ld", prevCount, currCount);
    [self deleteAllCacheStack];
    [self rebuildCacheStack];
    [self rebuildScrollSubViews];
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
