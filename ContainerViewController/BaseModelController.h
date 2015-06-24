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
    NSArray *titleArray;
}
@property(nonatomic, strong) NSString *idInStoryBoard;
@property(nonatomic, assign, readonly) NSUInteger count;
@property(nonatomic, assign, readonly) NSArray *titleArray;

- (instancetype)initWithId:(NSString *)idInStoryBoard;
- (UIViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
@end
