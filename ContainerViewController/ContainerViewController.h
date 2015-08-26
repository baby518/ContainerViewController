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
- (void)initScrollSubViews;
- (void)setupScrollModel;
- (void)setModelController:(BaseModelController *)modelController;
- (void)setModelController:(BaseModelController *)modelController startIndex:(NSUInteger)index;
- (void)setModelController:(BaseModelController *)modelController startIndex:(NSUInteger)index cacheSize:(NSUInteger)cacheSize;
- (void)gotoViewControllerAtIndex:(NSUInteger)index;
- (void)viewDidBringToFront:(UIViewController *)viewController atIndex:(NSUInteger)index;
- (void)viewDidReturnToBack:(UIViewController *)viewController atIndex:(NSUInteger)index;
@end
