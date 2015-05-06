//
//  ChildViewController.h
//  ContainerViewControllerDemo
//
//  Created by zhangchao on 15/4/21.
//  Copyright (c) 2015年 zhangchao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DemoChildViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
@property (strong, nonatomic) IBOutlet UITextField *pageNumberTextField;
@property (strong, nonatomic) IBOutlet UIStepper *pageNumberStepper;
@property (strong, nonatomic) id data;
@property (assign, nonatomic) NSUInteger pageNumber;
@property (assign, nonatomic) NSUInteger pageCount;

- (IBAction)pageNumberStepperChanged:(UIStepper *)sender;
- (IBAction)jumpAction:(UIButton *)sender;
@end
