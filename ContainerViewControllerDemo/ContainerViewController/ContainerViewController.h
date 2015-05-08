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
@property(nonatomic, assign, readonly) BOOL useScrollView;
@property(nonatomic, assign, readonly) NSUInteger count;
@property(nonatomic, assign, readonly) NSUInteger currentIndex;
@property(strong, nonatomic) BaseModelController *modelController;

/* doit in awakeFromNib which is before viewDidLoad.*/
- (void)setupScrollModel;
- (void)setModelController:(BaseModelController *)modelController;
- (void)setModelController:(BaseModelController *)modelController startIndex:(NSUInteger)index;
- (void)setModelController:(BaseModelController *)modelController startIndex:(NSUInteger)index useScrollView:(BOOL)useScrollView;
- (void)setModelController:(BaseModelController *)modelController startIndex:(NSUInteger)index useScrollView:(BOOL)useScrollView useLargeReuse:(BOOL)useLargeReuse;
- (void)gotoViewControllerAtIndex:(NSUInteger)index;
- (void)viewDidBringToFront:(NSUInteger)index;
@end
