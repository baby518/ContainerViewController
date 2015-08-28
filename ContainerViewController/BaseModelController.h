//
//  ModelController.h
//  ContainerViewControllerDemo
//
//  Created by zhangchao on 15/4/21.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BaseModelController : NSObject {
@protected
    NSMutableArray *titleArray;
}
@property(nonatomic, strong) NSString *idInStoryBoard;
@property(nonatomic, assign, readonly) NSUInteger count;

- (instancetype)initWithId:(NSString *)idInStoryBoard;
- (UIViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;

- (NSMutableArray *)titleArray;

- (void)addChildWithTitle:(NSString *)title;
- (void)delChildAtIndex:(NSUInteger)index;
@end
