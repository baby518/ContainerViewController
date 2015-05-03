//
//  ChildViewController.m
//  ContainerViewControllerDemo
//
//  Created by zhangchao on 15/4/21.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "BaseChildViewController.h"
#import "ContainerViewController.h"

@interface BaseChildViewController ()

@end

@implementation BaseChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

//    NSLog(@"viewDidLoad parentDelegate isUseScrollView : %d", self.parentDelegate == nil ? -1 : self.parentDelegate.isUseScrollView);

    if (self.parentDelegate != nil && !self.parentDelegate.isUseScrollView) {
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self.view addGestureRecognizer:swipeLeft];

        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [self.view addGestureRecognizer:swipeRight];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)swipeToNextViewController {
    if (self.parentDelegate != nil) {
        [self.parentDelegate swipeToNextViewController];
    }
}
- (void)swipeToPrevViewController {
    if (self.parentDelegate != nil) {
        [self.parentDelegate swipeToPrevViewController];
    }
}
- (void)gotoViewControllerAtIndex:(NSUInteger)index {
    if (self.parentDelegate != nil) {
        [self.parentDelegate gotoViewControllerAtIndex:index];
    }
}

- (void)viewDidBringToFront {

}
#pragma mark - Handle Gesture
- (void)handleSwipeGesture:(UIGestureRecognizer *)gestureRecognizer {
//    NSLog(@"handleSwipeGesture %@", gestureRecognizer.description);
    if ([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
        if (((UISwipeGestureRecognizer *) gestureRecognizer).direction == UISwipeGestureRecognizerDirectionRight) {
            [self swipeToPrevViewController];
        } else if (((UISwipeGestureRecognizer *) gestureRecognizer).direction == UISwipeGestureRecognizerDirectionLeft) {
            [self swipeToNextViewController];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
