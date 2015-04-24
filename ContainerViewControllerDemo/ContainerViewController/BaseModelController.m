//
//  ModelController.m
//  ContainerViewControllerDemo
//
//  Created by zhangchao on 15/4/21.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "BaseModelController.h"
#import "BaseChildViewController.h"
#import "ContainerViewController.h"

@interface BaseModelController ()
@end

@implementation BaseModelController

- (instancetype)initWithCount:(NSUInteger)count {
    self = [super init];
    if (self) {
        _count = count;
    }
    return self;
}

- (BaseChildViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    // Subclasses must override this method。
    [self doesNotRecognizeSelector:@selector(viewControllerAtIndex::)];
    return [[BaseChildViewController alloc] init];
}

@end
