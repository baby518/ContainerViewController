//
//  ZCContainerViewController.h
//  ContainerViewControllerDemo
//
//  Created by zhangchao on 15/4/21.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseModelController.h"

@interface ContainerViewController : UIViewController
@property(nonatomic, assign, readonly) NSUInteger count;
@property(nonatomic, assign, readonly) NSUInteger currentIndex;
@property(strong, nonatomic) BaseModelController *modelController;
@property(strong, nonatomic) UIColor *barTintColor;
@property(assign, nonatomic) CGFloat navigationScrollHeight;

/* do it in awakeFromNib which is before viewDidLoad.*/
- (void)setupScrollModel;
- (void)gotoViewControllerAtIndex:(NSUInteger)index;
- (void)viewDidBringToFront:(UIViewController *)viewController atIndex:(NSUInteger)index;
- (void)viewDidReturnToBack:(UIViewController *)viewController atIndex:(NSUInteger)index;

- (void)rebuildCacheStack;
- (void)rebuildCacheStack:(NSUInteger)startIndex;
- (void)rebuildCacheStack:(NSUInteger)startIndex withCacheSize:(NSUInteger)cacheSize;
@end
