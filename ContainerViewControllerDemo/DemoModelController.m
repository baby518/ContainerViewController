//
//  ModelController.m
//  ContainerViewControllerDemo
//
//  Created by zhangchao on 15/4/21.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "DemoModelController.h"

@interface DemoModelController ()
@end

@implementation DemoModelController

- (instancetype)initWithId:(NSString *)idInStoryBoard {
    self = [super initWithId:idInStoryBoard];
    if (self) {
        // Create the data model.
        titleArray = @[@"AAAAAA", @"BB", @"CCCC", @"DDDDD123456", @"ESSS", @"FFF", @"GGGGG", @"H456456", @"I123123", @"JJJKJKJKJ"];

        count = titleArray.count;
    }
    return self;
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    return [self viewControllerAtIndex:index storyboard:storyboard childID:self.idInStoryBoard];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard childID:(NSString *)idString {
    // Return the data view controller for the given index.
    if ((self.count == 0) || (index >= self.count)) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    DemoChildViewController *childViewController = [storyboard instantiateViewControllerWithIdentifier:idString];
    childViewController.data = self.titleArray[index];
    childViewController.pageNumber = index + 1;
    childViewController.pageCount = self.count;

    return childViewController;
}

@end
