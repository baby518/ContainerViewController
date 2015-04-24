//
//  ModelController.h
//  ContainerViewControllerDemo
//
//  Created by zhangchao on 15/4/21.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ContainerParentDelegate;
@class BaseChildViewController;

@interface BaseModelController : NSObject
@property (nonatomic, assign) id <ContainerParentDelegate> parentDelegate;
@property(nonatomic, assign) NSUInteger count;

- (BaseChildViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
@end
