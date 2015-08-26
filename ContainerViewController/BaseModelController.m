//
//  ModelController.m
//  ContainerViewControllerDemo
//
//  Created by zhangchao on 15/4/21.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "BaseModelController.h"

@interface BaseModelController ()
@end

@implementation BaseModelController

- (instancetype)initWithId:(NSString *)idInStoryBoard {
    self = [super init];
    if (self) {
        _idInStoryBoard = idInStoryBoard;
    }
    return self;
}

- (NSUInteger)count {
    return titleArray == nil ? 0 : titleArray.count;
}

- (NSArray *)titleArray {
    return titleArray;
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    // Subclasses must override this method。
    [self doesNotRecognizeSelector:@selector(viewControllerAtIndex::)];
    return nil;
}

@end
