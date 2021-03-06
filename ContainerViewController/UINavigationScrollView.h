//
//  UINavigationScrollView.h
//  ContainerViewControllerDemo
//
//  Created by zhangchao on 15/5/8.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UINavigationScrollDelegate <NSObject>
- (void)indexChanged:(NSUInteger)index;
@end

@interface UINavigationScrollView : UIView
@property(assign, nonatomic) NSUInteger index;
@property(strong, nonatomic, readonly) UIScrollView *scrollView;
@property(weak, nonatomic) id <UINavigationScrollDelegate> delegate;
@property(nonatomic, strong) UIColor *barTintColor;

- (instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray *)titles;

- (NSUInteger)titleCount;

- (BOOL)highLightIndex:(NSUInteger)index;
@end
