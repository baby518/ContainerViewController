//
//  ModelController.m
//  ContainerViewControllerDemo
//
//  Created by zhangchao on 15/4/21.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "DemoModelController.h"
NSString *const IDInStoryBoard = @"ChildViewController";

@interface DemoModelController ()
@property (strong, nonatomic, readonly) NSArray *dataArray;
@end

@implementation DemoModelController

- (instancetype)init {
    self = [super init];
    if (self) {
        // Create the data model.
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        _dataArray = [[dateFormatter weekdaySymbols] copy];
//        _dataArray = @[@"A", @"B"];
        
        self.count = _dataArray.count;
    }
    return self;
}

- (BaseChildViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    return [self viewControllerAtIndex:index storyboard:storyboard childID:IDInStoryBoard];
}

- (BaseChildViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard childID:(NSString *)idString {
    // Return the data view controller for the given index.
    if (([self.dataArray count] == 0) || (index >= [self.dataArray count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    DemoChildViewController *childViewController = [storyboard instantiateViewControllerWithIdentifier:idString];
    childViewController.data = self.dataArray[index];
    childViewController.pageNumber = index + 1;
    childViewController.pageCount = self.count;

    return childViewController;
}

@end
