//
//  UINavigationScrollView.h
//  ContainerViewControllerDemo
//
//  Created by zhangchao on 15/5/8.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationScrollView : UIView
@property(strong, nonatomic, readonly) UIScrollView *scrollView;

- (instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray *)titles;
@end
