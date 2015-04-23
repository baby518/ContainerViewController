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

    NSLog(@"parent is ContainerViewController : %d", [self.parentViewController isKindOfClass:[ContainerViewController class]]);

//    if ([self.parentViewController isKindOfClass:[ContainerViewController class]]
//            && !((ContainerViewController *) self.parentViewController).useScrollView) {
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self.view addGestureRecognizer:swipeLeft];

        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [self.view addGestureRecognizer:swipeRight];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Handle Gesture
- (void)handleSwipeGesture:(UIGestureRecognizer *)gestureRecognizer {
//    NSLog(@"handleSwipeGesture %@", gestureRecognizer.description);
    if ([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
        if (((UISwipeGestureRecognizer *) gestureRecognizer).direction == UISwipeGestureRecognizerDirectionRight) {
            [(ContainerViewController *) self.parentViewController swapToPrevViewController];
        } else if (((UISwipeGestureRecognizer *) gestureRecognizer).direction == UISwipeGestureRecognizerDirectionLeft) {
            [(ContainerViewController *) self.parentViewController swapToNextViewController];
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
