//
//  DemoViewController.m
//  ContainerViewControllerDemo
//
//  Created by zhangchao on 15/5/8.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "DemoViewController.h"
#import "DemoModelController.h"

NSString *const IDInStoryBoard = @"ChildViewController";
@interface DemoViewController ()

@end

@implementation DemoViewController

/* override from super*/
- (void)setupScrollModel {
    DemoModelController *modelController = [[DemoModelController alloc] initWithId:IDInStoryBoard];
    
    //    self.modelController = modelController;
    //    [self setModelController:modelController startIndex:4];
    //    [self setModelController:modelController startIndex:4 useScrollView:YES];
    [self setModelController:modelController startIndex:6 useScrollView:YES useLargeReuse:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
