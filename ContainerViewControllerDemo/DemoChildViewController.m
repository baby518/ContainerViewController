//
//  ChildViewController.m
//  ContainerViewControllerDemo
//
//  Created by zhangchao on 15/4/21.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import "DemoChildViewController.h"

@interface DemoChildViewController ()

@end

@implementation DemoChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pageNumberStepper.stepValue = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dataLabel.text = [self.data description];
    self.pageNumberTextField.text = [NSString stringWithFormat:@"%lu/%lu", self.pageNumber, self.pageCount];
    self.pageNumberStepper.maximumValue = self.pageCount;
    self.pageNumberStepper.minimumValue = 1;
    self.pageNumberStepper.value = self.pageNumber;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)pageNumberStepperChanged:(UIStepper *)sender {
    int stepValue = sender.value;
    self.pageNumber = stepValue;
    self.pageNumberTextField.text = [NSString stringWithFormat:@"%lu/%lu", self.pageNumber, self.pageCount];
}

- (IBAction)jumpAction:(UIButton *)sender {
    if (self.pageNumberStepper.value >= 0) {
        NSUInteger index = (NSUInteger)self.pageNumberStepper.value - 1;
        [self gotoViewControllerAtIndex:index];
    }
}
@end
