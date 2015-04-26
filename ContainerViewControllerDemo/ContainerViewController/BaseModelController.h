//
//  ModelController.h
//  ContainerViewControllerDemo
//
//  Created by zhangchao on 15/4/21.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class BaseChildViewController;

@interface BaseModelController : NSObject {
@protected
    NSUInteger count;
}
@property(nonatomic, strong) NSString *idInStoryBoard;
@property(nonatomic, assign, readonly) NSUInteger count;

- (instancetype)initWithId:(NSString *)idInStoryBoard;
- (BaseChildViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
@end
