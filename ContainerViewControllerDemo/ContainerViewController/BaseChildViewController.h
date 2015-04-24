//
//  ChildViewController.h
//  ContainerViewControllerDemo
//
//  Created by zhangchao on 15/4/21.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ContainerParentDelegate;

@interface BaseChildViewController : UIViewController
@property (nonatomic, assign) id <ContainerParentDelegate> parentDelegate;

- (void)swipeToNextViewController;
- (void)swipeToPrevViewController;
- (void)gotoViewControllerAtIndex:(NSUInteger)index;
@end
